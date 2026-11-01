// Read-only. Paste into use_figma after replacing NODE_ID.
// Lists the screens to export under a PAGE, SECTION or FRAME:
//   PAGE    -> visible direct FRAME/COMPONENT children + those of direct SECTIONs
//   SECTION -> visible direct FRAME/COMPONENT children (+ nested SECTIONs one level down)
//   FRAME   -> the frame itself
// Never recurses into a frame, so nav bars, cards and inner layout frames are not treated as screens.
const NODE_ID = "REPLACE_ME"; // "123:456" form
const SCREEN = new Set(["FRAME", "COMPONENT", "COMPONENT_SET", "INSTANCE"]);
const root = await figma.getNodeByIdAsync(NODE_ID);
if (!root) throw new Error("Node not found: " + NODE_ID);
let page = root;
while (page.type !== "PAGE") page = page.parent;
await figma.setCurrentPageAsync(page);

const out = [];
const add = (n, section) => {
  if (!n.visible || !SCREEN.has(n.type)) return;
  // Up to 3 short texts help name frames still called "Frame 123".
  const texts = n.findAllWithCriteria({ types: ["TEXT"] })
    .filter(t => t.visible && t.characters.trim())
    .slice(0, 3).map(t => t.characters.trim().slice(0, 30));
  out.push({ id: n.id, name: n.name, section, w: Math.round(n.width), h: Math.round(n.height),
             x: Math.round(n.absoluteTransform[0][2]), y: Math.round(n.absoluteTransform[1][2]),
             generic: /^(Frame|Group|Rectangle)\s*\d*$/i.test(n.name), texts });
};
const walkContainer = (c, section, depth) => {
  for (const ch of c.children) {
    if (ch.type === "SECTION" && depth < 2) { if (ch.visible) walkContainer(ch, ch.name, depth + 1); }
    else add(ch, section);
  }
};
if (root.type === "PAGE") walkContainer(root, "", 0);
else if (root.type === "SECTION") walkContainer(root, root.name, 1);
else add(root, root.parent && root.parent.type === "SECTION" ? root.parent.name : "");

// Reading order: section, then rows (y within 200px), then x.
out.sort((a, b) => a.section.localeCompare(b.section) || (Math.abs(a.y - b.y) > 200 ? a.y - b.y : a.x - b.x));
return { source: { id: root.id, type: root.type, name: root.name, page: page.name }, count: out.length, frames: out };
