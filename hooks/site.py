"""MkDocs hook that lets the site grow without editing any config.

It does four things:

1. Names sidebar sections. A folder with a README.md (or index.md) is named
   after that page's first heading; a top-level folder uses
   `extra.section_titles` from mkdocs.yml, or a title made from its name.
2. Fills the `<!-- lessons -->` marker on the home page with a card for every
   page, grouped by top-level folder, using each page's heading and first
   paragraph.
3. Rewrites links to files outside docs/ (manifests, Terraform code) so they
   point at the repository on GitHub instead of breaking.
4. Renders Markdown inside `<details>` blocks, which GitHub does and plain
   MkDocs doesn't.
"""

from __future__ import annotations

import posixpath
import re
from pathlib import Path

from mkdocs.structure.nav import Section

INDEX_NAMES = {"readme.md", "index.md"}
LESSONS_MARKER = "<!-- lessons -->"

_H1 = re.compile(r"^#\s+(.+?)\s*#*\s*$", re.MULTILINE)
_FRONT_MATTER = re.compile(r"\A---\s*\n(.*?)\n---\s*\n", re.DOTALL)
_LINK = re.compile(r"(\[[^\]]*\]\()([^)\s]+)(\))")
_DETAILS = re.compile(r"<details(?![^>]*\bmarkdown=)([^>]*)>")
_MD_LINK_TEXT = re.compile(r"\[([^\]]*)\]\([^)]*\)")


def _humanize(name: str) -> str:
    name = re.sub(r"^\d+[-_ ]*", "", name)
    name = name.replace("-", " ").replace("_", " ").strip()
    return name[:1].upper() + name[1:]


def _read_page_info(path: Path) -> tuple[str | None, str | None]:
    """Return (title, summary) from front matter or the first heading and paragraph."""
    text = path.read_text(encoding="utf-8")
    meta: dict[str, str] = {}
    fm = _FRONT_MATTER.match(text)
    if fm:
        for line in fm.group(1).splitlines():
            key, sep, value = line.partition(":")
            if sep:
                meta[key.strip()] = value.strip().strip("'\"")
        text = text[fm.end():]

    title = meta.get("title")
    summary = meta.get("description")
    h1 = _H1.search(text)
    if not title and h1:
        title = h1.group(1)
    if not summary:
        body = text[h1.end():] if h1 else text
        for block in re.split(r"\n\s*\n", body):
            block = block.strip()
            if block and not block.startswith(("#", "|", "```", "<", "-", "*", ">", "!")):
                summary = " ".join(block.split())
                break
    if summary:
        summary = _MD_LINK_TEXT.sub(r"\1", summary)  # links would be relative to the wrong page
    return title, summary


def _section_title(folder: str, config) -> str:
    return config.extra.get("section_titles", {}).get(folder) or _humanize(folder)


# --- 1. Sidebar section names -------------------------------------------------

def _first_file(section):
    """The first page file anywhere inside a nav section."""
    for child in section.children:
        if getattr(child, "file", None):
            return child.file
        if isinstance(child, Section):
            found = _first_file(child)
            if found:
                return found
    return None


def on_nav(nav, config, files):
    docs_dir = Path(config.docs_dir)

    def visit(items, depth):
        for item in items:
            if not isinstance(item, Section):
                continue
            index = next(
                (c for c in item.children
                 if getattr(c, "file", None) and posixpath.basename(c.file.src_uri).lower() in INDEX_NAMES),
                None,
            )
            first = _first_file(item)
            folder = first.src_uri.split("/")[depth] if first else None
            if depth == 0 and folder:
                item.title = _section_title(folder, config)
            elif index is not None:
                title, _ = _read_page_info(docs_dir / index.file.src_uri)
                if title:
                    item.title = title
            visit(item.children, depth + 1)

    visit(nav.items, 0)
    return nav


# --- 2-4. Page Markdown --------------------------------------------------------

def _lesson_cards(page, config, files) -> str:
    docs_dir = Path(config.docs_dir)
    groups: dict[str, list] = {}
    for f in sorted(files.documentation_pages(), key=lambda f: f.src_uri):
        if f.src_uri == page.file.src_uri or "/" not in f.src_uri:
            continue
        groups.setdefault(f.src_uri.split("/")[0], []).append(f)

    here = posixpath.dirname(page.file.src_uri)
    blurbs = config.extra.get("section_blurbs", {})
    out = []
    for folder, pages in groups.items():
        out.append(f"## {_section_title(folder, config)}\n")
        if blurbs.get(folder):
            out.append(f"{blurbs[folder]}\n")
        out.append('<div class="grid cards" markdown>\n')
        for f in pages:
            title, summary = _read_page_info(docs_dir / f.src_uri)
            link = posixpath.relpath(f.src_uri, here or ".")
            out.append(f"-   **[{title or _humanize(Path(f.src_uri).parent.name)}]({link})**\n")
            out.append("    ---\n")
            if summary:
                out.append(f"    {summary}\n")
        out.append("</div>\n")
    return "\n".join(out)


def on_page_markdown(markdown, page, config, files):
    # 2. Home page lesson list
    if LESSONS_MARKER in markdown:
        markdown = markdown.replace(LESSONS_MARKER, _lesson_cards(page, config, files))

    # 3. Links that leave docs/ go to GitHub
    repo_url = (config.repo_url or "").rstrip("/")
    branch = "main"
    m = re.match(r"edit/([^/]+)/", config.edit_uri or "")
    if m:
        branch = m.group(1)
    page_dir = posixpath.join("docs", posixpath.dirname(page.file.src_uri))

    def fix_link(match):
        target = match.group(2)
        if re.match(r"^[a-z][a-z0-9+.-]*:|^#|^/", target, re.IGNORECASE) or not repo_url:
            return match.group(0)
        path, _, anchor = target.partition("#")
        resolved = posixpath.normpath(posixpath.join(page_dir, path))
        if resolved == "docs" or resolved.startswith("docs/") or resolved.startswith(".."):
            return match.group(0)
        url = f"{repo_url}/tree/{branch}/{resolved}" + (f"#{anchor}" if anchor else "")
        return f"{match.group(1)}{url}{match.group(3)}"

    markdown = _LINK.sub(fix_link, markdown)

    # 4. Markdown inside <details>
    markdown = _DETAILS.sub(r'<details\1 markdown="1">', markdown)
    return markdown
