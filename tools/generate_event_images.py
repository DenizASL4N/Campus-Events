"""Draws the six event illustrations and the app icon.

All images are original artwork created by this script (no third-party
images). Run from the project root:

    python tools/generate_event_images.py

Requires Pillow. Output: assets/images/<event>.png (1200x800) and
assets/icon/app_icon*.png (1024x1024). After changing the icon, run
`dart run flutter_launcher_icons` to update the platform icon files.
"""
import math
import pathlib
import random

from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1200, 800
S = 2  # supersampling factor for smooth edges

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "images"
FONT = ROOT / "assets" / "fonts" / "Poppins-Bold.ttf"


def rgba(hex_color, alpha=255):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4)) + (alpha,)


class Canvas:
    """Draws in 1200x800 coordinates on a supersampled RGBA image."""

    def __init__(self, top, bottom, middle=None, size=(W, H)):
        # RGB base + "RGBA" draw mode makes translucent fills blend correctly.
        self.size = size
        self.img = Image.new("RGB", (size[0] * S, size[1] * S))
        d = ImageDraw.Draw(self.img)
        stops = [rgba(top), rgba(middle), rgba(bottom)] if middle else [rgba(top), rgba(bottom)]
        for y in range(size[1] * S):
            t = y / (size[1] * S - 1) * (len(stops) - 1)
            i = min(int(t), len(stops) - 2)
            f = t - i
            c = tuple(int(stops[i][k] + (stops[i + 1][k] - stops[i][k]) * f) for k in range(3))
            d.line([(0, y), (size[0] * S, y)], fill=c)
        self.d = ImageDraw.Draw(self.img, "RGBA")

    @staticmethod
    def _s(values):
        return [v * S for v in values]

    def rect(self, x0, y0, x1, y1, fill=None, r=0, outline=None, width=0):
        self.d.rounded_rectangle(self._s([x0, y0, x1, y1]), radius=r * S, fill=fill,
                                 outline=outline, width=width * S)

    def ellipse(self, cx, cy, rx, ry, fill=None, outline=None, width=0):
        self.d.ellipse(self._s([cx - rx, cy - ry, cx + rx, cy + ry]), fill=fill,
                       outline=outline, width=width * S)

    def circle(self, cx, cy, r, fill=None, outline=None, width=0):
        self.ellipse(cx, cy, r, r, fill, outline, width)

    def poly(self, points, fill):
        self.d.polygon([(x * S, y * S) for x, y in points], fill=fill)

    def line(self, points, fill, width):
        pts = [(x * S, y * S) for x, y in points]
        self.d.line(pts, fill=fill, width=width * S, joint="curve")
        for x, y in (pts[0], pts[-1]):  # round caps
            r = width * S / 2
            self.d.ellipse([x - r, y - r, x + r, y + r], fill=fill)

    def arc(self, cx, cy, rx, ry, start, end, fill, width):
        self.d.arc(self._s([cx - rx, cy - ry, cx + rx, cy + ry]), start, end, fill=fill,
                   width=width * S)

    def text(self, x, y, s, size, fill, anchor="mm"):
        font = ImageFont.truetype(str(FONT), size * S)
        self.d.text((x * S, y * S), s, font=font, fill=fill, anchor=anchor)

    def glow(self, draw_fn, color, blur=30):
        """Runs draw_fn on a separate layer, blurs it and adds it as a glow.

        The transparent background uses [color] so the blur fades the glow
        out instead of darkening it towards black.
        """
        layer = Canvas.__new__(Canvas)
        layer.img = Image.new("RGBA", self.img.size, rgba(color, 0))
        layer.d = ImageDraw.Draw(layer.img, "RGBA")
        draw_fn(layer)
        blurred = layer.img.filter(ImageFilter.GaussianBlur(blur * S))
        base = self.img.convert("RGBA")
        base.alpha_composite(blurred)
        self.img = base.convert("RGB")
        self.d = ImageDraw.Draw(self.img, "RGBA")

    def paste(self, other, x, y):
        """Pastes another Canvas at (x, y); it is clipped to its own size."""
        self.img.paste(other.img, (int(x * S), int(y * S)))
        self.d = ImageDraw.Draw(self.img, "RGBA")

    @classmethod
    def transparent(cls, size):
        """A canvas with a fully transparent background (for icon layers)."""
        c = cls.__new__(cls)
        c.size = size
        c.img = Image.new("RGBA", (size[0] * S, size[1] * S), (0, 0, 0, 0))
        c.d = ImageDraw.Draw(c.img, "RGBA")
        return c

    def save(self, name, out_dir=OUT):
        out = self.img.resize(self.size, Image.LANCZOS)
        path = out_dir / name
        out.save(path, optimize=True)
        print(path.relative_to(ROOT), path.stat().st_size // 1024, "KB")


def bubbles(c, rng, color, count, rmin, rmax, alpha=(15, 40)):
    for _ in range(count):
        c.circle(rng.uniform(0, W), rng.uniform(0, H), rng.uniform(rmin, rmax),
                 fill=rgba(color, rng.randint(*alpha)))


# 1. Flutter Workshop for Beginners — laptop with code and a phone preview.
def flutter_workshop():
    rng = random.Random(1)
    c = Canvas("#1E3A8A", "#38BDF8")
    bubbles(c, rng, "#FFFFFF", 14, 20, 90)
    for x in range(40, W, 60):  # dotted grid
        for y in range(40, 560, 60):
            c.circle(x, y, 2.5, fill=rgba("#FFFFFF", 45))
    c.rect(0, 600, W, H, fill=rgba("#0F172A", 90))  # desk
    c.ellipse(600, 600, 430, 26, fill=rgba("#0F172A", 80))
    # laptop
    c.rect(330, 160, 870, 520, fill=rgba("#0F172A"), r=26)
    c.rect(352, 182, 848, 498, fill=rgba("#111827"), r=12)
    c.rect(352, 182, 848, 220, fill=rgba("#1F2937"), r=12)
    for i, col in enumerate(["#F87171", "#FBBF24", "#34D399"]):
        c.circle(378 + i * 26, 201, 7, fill=rgba(col))
    code = [(0, 180, "#F472B6"), (1, 240, "#60A5FA"), (2, 150, "#34D399"), (2, 210, "#FBBF24"),
            (1, 120, "#60A5FA"), (2, 260, "#A78BFA"), (3, 170, "#34D399"), (1, 90, "#F472B6")]
    y = 245
    for indent, length, col in code:
        c.rect(380 + indent * 34, y, 380 + indent * 34 + length, y + 14, fill=rgba(col), r=7)
        c.rect(380 + indent * 34 + length + 14, y, 380 + indent * 34 + length + 60, y + 14,
               fill=rgba("#475569"), r=7)
        y += 30
    c.poly([(250, 520), (950, 520), (1000, 575), (200, 575)], fill=rgba("#CBD5E1"))
    c.rect(540, 520, 660, 532, fill=rgba("#94A3B8"), r=6)
    # phone preview on the left
    c.rect(95, 230, 255, 540, fill=rgba("#F8FAFC"), r=28)
    c.rect(110, 260, 240, 510, fill=rgba("#E0F2FE"), r=14)
    c.rect(122, 274, 228, 330, fill=rgba("#3B82F6"), r=10)
    for i in range(3):
        c.rect(122, 345 + i * 52, 228, 385 + i * 52, fill=rgba("#FFFFFF"), r=10)
        c.circle(142, 365 + i * 52, 11, fill=rgba(["#F472B6", "#34D399", "#FBBF24"][i]))
    c.rect(150, 240, 200, 248, fill=rgba("#CBD5E1"), r=4)
    # floating code badge
    c.glow(lambda g: g.circle(1000, 200, 95, fill=rgba("#FFFFFF", 120)), "#FFFFFF", blur=25)
    c.circle(1000, 200, 82, fill=rgba("#FFFFFF"))
    c.text(1000, 205, "</>", 58, rgba("#1D4ED8"))
    c.circle(1080, 420, 34, fill=rgba("#FBBF24"))
    c.text(1080, 423, "{ }", 26, rgba("#78350F"))
    # mug
    c.rect(990, 520, 1070, 610, fill=rgba("#F472B6"), r=14)
    c.arc(1072, 562, 26, 26, -90, 90, rgba("#F472B6"), 12)
    c.save("flutter_workshop.png")


# 2. AI and Society Panel — neural network above three speakers.
def ai_panel():
    rng = random.Random(2)
    c = Canvas("#1E1B4B", "#6D28D9", middle="#3730A3")
    for _ in range(80):
        c.circle(rng.uniform(0, W), rng.uniform(0, 500), rng.uniform(1, 2.5),
                 fill=rgba("#FFFFFF", rng.randint(60, 160)))
    layers = [3, 5, 6, 5, 3]
    xs = [220, 410, 600, 790, 980]
    nodes = []
    for x, n in zip(xs, layers):
        top = 300 - (n - 1) * 45
        nodes.append([(x, top + i * 90 - 40) for i in range(n)])
    for a, b in zip(nodes, nodes[1:]):
        for p in a:
            for q in b:
                c.line([p, q], fill=rgba("#A5B4FC", 55), width=2)

    def node_glow(g):
        for layer in nodes:
            for x, y in layer:
                g.circle(x, y, 22, fill=rgba("#22D3EE", 160))
    c.glow(node_glow, "#22D3EE", blur=14)
    palette = ["#22D3EE", "#F472B6", "#A78BFA", "#34D399", "#FBBF24"]
    for i, layer in enumerate(nodes):
        for x, y in layer:
            c.circle(x, y, 16, fill=rgba(palette[i]))
            c.circle(x, y, 7, fill=rgba("#FFFFFF", 200))
    # panel table with three speakers
    skin = ["#F1C27D", "#8D5524", "#E0AC69"]
    shirts = ["#F472B6", "#22D3EE", "#FBBF24"]
    for i, x in enumerate([360, 600, 840]):
        c.ellipse(x, 640, 85, 70, fill=rgba(shirts[i]))
        c.circle(x, 548, 42, fill=rgba(skin[i]))
        c.ellipse(x, 520, 44, 24, fill=rgba(["#1F2937", "#111827", "#7C2D12"][i]))
        c.line([(x + 50, 668), (x + 30, 602)], fill=rgba("#0F172A"), width=6)
        c.ellipse(x + 28, 596, 10, 13, fill=rgba("#0F172A"))
    c.rect(150, 650, 1050, 680, fill=rgba("#F8FAFC"), r=10)
    c.rect(185, 680, 1015, 800, fill=rgba("#4F46E5"))
    c.text(600, 742, "AI & SOCIETY", 46, rgba("#FFFFFF"))
    c.save("ai_panel.png")


def autumn_tree(c, x0, y0, x1, y1, rng):
    """A tiny autumn landscape, drawn on its own canvas so it stays inside the frame."""
    w, h = int(x1 - x0), int(y1 - y0)
    p = Canvas("#FDBA74", "#FDE68A", size=(w, h))
    p.circle(w * 0.78, h * 0.25, w * 0.1, fill=rgba("#FEF3C7"))
    p.ellipse(w * 0.3, h, w * 0.6, h * 0.35, fill=rgba("#B45309"))
    p.ellipse(w * 0.85, h, w * 0.5, h * 0.25, fill=rgba("#92400E"))
    tx = w * rng.uniform(0.35, 0.6)
    p.rect(tx - w * 0.03, h * 0.45, tx + w * 0.03, h * 0.85, fill=rgba("#451A03"))
    for col, dx, dy, r in [("#DC2626", -0.12, 0.38, 0.2), ("#EA580C", 0.1, 0.35, 0.19),
                           ("#F59E0B", 0, 0.25, 0.2)]:
        p.circle(tx + w * dx, h * dy, w * r, fill=rgba(col))
    c.paste(p, x0, y0)


def leaf(c, x, y, size, angle, color):
    pts = []
    for t in range(0, 360, 20):
        a = math.radians(t)
        px = math.cos(a) * size
        py = math.sin(a) * size * 0.45
        ca, sa = math.cos(angle), math.sin(angle)
        pts.append((x + px * ca - py * sa, y + px * sa + py * ca))
    c.poly(pts, fill=rgba(color))


# 3. Autumn Photography Exhibition — gallery wall with three framed photos.
def photography_exhibition():
    rng = random.Random(3)
    c = Canvas("#FFF7ED", "#FED7AA")
    c.rect(0, 600, W, H, fill=rgba("#9A3412"))
    for x in range(0, W, 120):
        c.line([(x, 600), (x - 60, 800)], fill=rgba("#7C2D12", 120), width=3)
    c.rect(0, 590, W, 604, fill=rgba("#7C2D12"))
    frames = [(110, 170, 390, 450), (460, 120, 740, 500), (810, 170, 1090, 450)]
    for x0, y0, x1, y1 in frames:
        cx = (x0 + x1) / 2
        c.poly([(cx - 20, 0), (cx + 20, 0), (x1 + 30, y1 + 120), (x0 - 30, y1 + 120)],
               fill=rgba("#FFFFFF", 55))
        c.rect(cx - 30, 0, cx + 30, 28, fill=rgba("#1F2937"), r=8)
    for x0, y0, x1, y1 in frames:
        c.rect(x0 + 10, y0 + 14, x1 + 10, y1 + 14, fill=rgba("#7C2D12", 60), r=6)
        c.rect(x0, y0, x1, y1, fill=rgba("#3F1D0B"), r=6)
        c.rect(x0 + 18, y0 + 18, x1 - 18, y1 - 18, fill=rgba("#FFFBEB"))
        autumn_tree(c, x0 + 40, y0 + 40, x1 - 40, y1 - 40, rng)
        c.rect((x0 + x1) / 2 - 45, y1 + 30, (x0 + x1) / 2 + 45, y1 + 52, fill=rgba("#FFFFFF"), r=4)
    for _ in range(18):
        leaf(c, rng.uniform(0, W), rng.uniform(20, 760), rng.uniform(14, 26),
             rng.uniform(0, math.pi), rng.choice(["#DC2626", "#EA580C", "#F59E0B", "#B45309"]))
    # camera badge
    c.glow(lambda g: g.circle(1080, 660, 90, fill=rgba("#000000", 90)), "#000000", blur=20)
    c.rect(985, 600, 1175, 730, fill=rgba("#1F2937"), r=22)
    c.rect(1010, 580, 1070, 606, fill=rgba("#1F2937"), r=8)
    c.circle(1080, 665, 50, fill=rgba("#E5E7EB"))
    c.circle(1080, 665, 36, fill=rgba("#111827"))
    c.circle(1068, 652, 10, fill=rgba("#FFFFFF", 180))
    c.circle(1150, 620, 8, fill=rgba("#F87171"))
    c.save("photography_exhibition.png")


def note(c, x, y, color, double=False):
    c.ellipse(x, y, 20, 15, fill=color)
    c.line([(x + 18, y), (x + 18, y - 80)], fill=color, width=6)
    if double:
        c.ellipse(x + 70, y - 12, 20, 15, fill=color)
        c.line([(x + 88, y - 12), (x + 88, y - 92)], fill=color, width=6)
        c.line([(x + 18, y - 80), (x + 88, y - 92)], fill=color, width=14)
    else:
        c.line([(x + 18, y - 80), (x + 46, y - 50)], fill=color, width=8)


# 4. Campus Choir Concert — choir on stage under spotlights.
def choir_concert():
    rng = random.Random(4)
    c = Canvas("#0F0C29", "#24243E", middle="#302B63")
    for _ in range(90):
        c.circle(rng.uniform(0, W), rng.uniform(0, 380), rng.uniform(1, 2.6),
                 fill=rgba("#FFFFFF", rng.randint(80, 200)))
    for x0, x1 in [(250, 120), (600, 600), (950, 1080)]:
        c.poly([(x0 - 25, 0), (x0 + 25, 0), (x1 + 230, 700), (x1 - 230, 700)],
               fill=rgba("#E9D5FF", 60))
    c.ellipse(600, 760, 680, 140, fill=rgba("#4C1D95"))
    c.ellipse(600, 745, 620, 110, fill=rgba("#6D28D9"))
    robes = ["#A78BFA", "#C4B5FD", "#8B5CF6"]
    skins = ["#F1C27D", "#C68642", "#E0AC69", "#8D5524", "#FFDBAC"]
    for row, (y, count, scale) in enumerate([(470, 9, 0.8), (545, 8, 0.9), (625, 7, 1.0)]):
        span = 860 * scale
        for i in range(count):
            x = 600 - span / 2 + span * i / (count - 1)
            c.ellipse(x, y + 60 * scale, 46 * scale, 70 * scale, fill=rgba(robes[row]))
            c.circle(x, y - 10 * scale, 26 * scale, fill=rgba(rng.choice(skins)))
            c.ellipse(x, y + 4 * scale, 8 * scale, 6 * scale, fill=rgba("#7F1D1D"))
    for side in (0, 1):  # curtains
        x0 = 0 if side == 0 else W - 120
        c.rect(x0, 0, x0 + 120, H, fill=rgba("#9F1239"))
        for k in range(4):
            fx = x0 + 15 + k * 30
            c.line([(fx, 0), (fx, H)], fill=rgba("#881337"), width=8)
    c.rect(0, 0, W, 40, fill=rgba("#881337"))
    c.glow(lambda g: note(g, 260, 260, rgba("#FBBF24")), "#FBBF24", blur=10)
    c.glow(lambda g: note(g, 860, 230, rgba("#F472B6"), True), "#F472B6", blur=10)
    note(c, 260, 260, rgba("#FBBF24"))
    note(c, 860, 230, rgba("#F472B6"), double=True)
    note(c, 560, 150, rgba("#67E8F9"))
    c.save("choir_concert.png")


# 5. Inter-Faculty Basketball Final — hoop, ball and scoreboard.
def basketball_final():
    rng = random.Random(5)
    c = Canvas("#111827", "#7C2D12", middle="#1F2937")
    for _ in range(260):  # crowd
        x, y = rng.uniform(0, W), rng.uniform(380, 560)
        c.circle(x, y, rng.uniform(6, 10), fill=rgba(rng.choice(
            ["#F87171", "#60A5FA", "#FBBF24", "#34D399", "#F472B6", "#E5E7EB"]), 150))
    for x in range(60, W, 220):  # arena lights
        c.glow(lambda g, x=x: g.circle(x, 40, 30, fill=rgba("#FEF3C7", 200)), "#FEF3C7", blur=18)
        c.rect(x - 30, 30, x + 30, 50, fill=rgba("#FEF9C3"), r=8)
    c.poly([(0, 560), (W, 560), (W, H), (0, H)], fill=rgba("#D97706"))
    for x in range(-200, W + 200, 70):
        c.line([(x, 560), (x - 120, 800)], fill=rgba("#B45309", 110), width=3)
    c.ellipse(600, 680, 260, 70, outline=rgba("#FFFFFF"), width=6)
    c.line([(600, 560), (600, 800)], fill=rgba("#FFFFFF"), width=6)
    c.line([(0, 566), (W, 566)], fill=rgba("#FFFFFF"), width=6)
    # hoop
    c.rect(1000, 150, 1018, 600, fill=rgba("#9CA3AF"))
    c.rect(800, 130, 1060, 300, fill=rgba("#F9FAFB"), r=8)
    c.rect(880, 190, 980, 270, outline=rgba("#EF4444"), width=6)
    for i in range(7):  # net
        x_top = 875 + i * 18
        x_bot = 900 + i * 11
        c.line([(x_top, 300), (x_bot, 390)], fill=rgba("#FFFFFF", 220), width=3)
    for y, (l, r) in [(330, (884, 1006)), (360, (893, 997))]:
        c.line([(l, y), (r, y)], fill=rgba("#FFFFFF", 200), width=3)
    c.ellipse(930, 300, 68, 14, outline=rgba("#F97316"), width=8)
    # ball with motion lines
    for i, y in enumerate([300, 340, 380]):
        c.line([(250 - i * 30, y), (400, y)], fill=rgba("#FDBA74", 140), width=8)
    bx, by, br = 560, 340, 115
    c.glow(lambda g: g.circle(bx, by, br + 10, fill=rgba("#FB923C", 200)), "#FB923C", blur=25)
    c.circle(bx, by, br, fill=rgba("#F97316"))
    c.circle(bx - 35, by - 40, 40, fill=rgba("#FDBA74", 90))
    c.line([(bx - br, by), (bx + br, by)], fill=rgba("#1C1917"), width=6)
    c.line([(bx, by - br), (bx, by + br)], fill=rgba("#1C1917"), width=6)
    c.arc(bx - 150, by, 110, 120, -40, 40, rgba("#1C1917"), 6)
    c.arc(bx + 150, by, 110, 120, 140, 220, rgba("#1C1917"), 6)
    # scoreboard
    c.rect(70, 120, 380, 280, fill=rgba("#0B0F19"), r=18, outline=rgba("#374151"), width=4)
    c.text(225, 160, "FINAL", 34, rgba("#FBBF24"))
    c.text(225, 228, "21 : 19", 58, rgba("#F87171"))
    c.save("basketball_final.png")


def runner(c, x, y, color, s=1.0, phase=0):
    c.circle(x + 18 * s, y - 120 * s, 20 * s, fill=color)
    c.line([(x + 10 * s, y - 95 * s), (x - 5 * s, y - 30 * s)], fill=color, width=int(24 * s))
    arm = 1 if phase == 0 else -1
    c.line([(x + 6 * s, y - 85 * s), (x + 40 * s * arm, y - 60 * s), (x + 60 * s * arm, y - 85 * s)],
           fill=color, width=int(15 * s))
    c.line([(x + 6 * s, y - 85 * s), (x - 35 * s * arm, y - 55 * s), (x - 50 * s * arm, y - 35 * s)],
           fill=color, width=int(15 * s))
    c.line([(x - 5 * s, y - 30 * s), (x + 30 * s, y + 5 * s), (x + 20 * s, y + 50 * s)],
           fill=color, width=int(17 * s))
    c.line([(x - 5 * s, y - 30 * s), (x - 40 * s, y + 5 * s), (x - 75 * s, y + 10 * s)],
           fill=color, width=int(17 * s))


# 6. Morning Campus Run (5K) — sunrise over hills and a running track.
def campus_run():
    rng = random.Random(6)
    c = Canvas("#FB7185", "#FEF3C7", middle="#FDBA74")
    c.glow(lambda g: g.circle(820, 430, 170, fill=rgba("#FFF7AD", 220)), "#FFF7AD", blur=40)
    c.circle(820, 430, 120, fill=rgba("#FFFBEB"))
    for _ in range(5):
        cx, cy = rng.uniform(100, 1100), rng.uniform(80, 250)
        for dx, r in [(-40, 30), (0, 42), (40, 32)]:
            c.circle(cx + dx, cy, r, fill=rgba("#FFF1F2"))
    c.ellipse(250, 560, 520, 180, fill=rgba("#6EE7B7"))
    c.ellipse(950, 580, 520, 170, fill=rgba("#34D399"))
    for x in [90, 170, 1010, 1100, 1160]:  # trees
        h = rng.uniform(90, 130)
        c.rect(x - 7, 520, x + 7, 560, fill=rgba("#78350F"))
        c.poly([(x, 520 - h), (x - 42, 530), (x + 42, 530)], fill=rgba("#047857"))
    c.ellipse(600, 900, 900, 380, fill=rgba("#C2410C"))
    for i, r in enumerate([860, 800, 740, 680]):
        c.ellipse(600, 900, r, 380 - (i + 1) * 40, outline=rgba("#FFFFFF", 200), width=4)
    c.ellipse(600, 900, 620, 220, fill=rgba("#10B981"))
    # finish flag
    c.rect(1040, 380, 1050, 640, fill=rgba("#374151"))
    c.poly([(1050, 385), (1170, 410), (1050, 450)], fill=rgba("#EF4444"))
    c.text(1093, 418, "5K", 28, rgba("#FFFFFF"))
    runner(c, 470, 640, rgba("#1E3A8A"), 1.05, 0)
    runner(c, 640, 660, rgba("#9D174D"), 1.0, 1)
    c.save("campus_run.png")


ICON_OUT = ROOT / "assets" / "icon"


def calendar_glyph(c):
    """White calendar with a check mark, centred on a 1024x1024 canvas."""
    c.rect(262, 300, 762, 780, fill=rgba("#FFFFFF"), r=70)
    c.rect(262, 300, 762, 430, fill=rgba("#F472B6"), r=70)
    c.rect(262, 380, 762, 430, fill=rgba("#F472B6"))
    for x in (390, 634):
        c.rect(x - 22, 240, x + 22, 350, fill=rgba("#3B0764"), r=22)
    c.line([(390, 600), (480, 690), (640, 520)], fill=rgba("#6D28D9"), width=58)


# App icon: full icon (iOS / legacy Android) and adaptive-icon foreground.
def app_icon():
    ICON_OUT.mkdir(parents=True, exist_ok=True)
    full = Canvas("#4C1D95", "#C026D3", middle="#7C3AED", size=(1024, 1024))
    full.glow(lambda g: g.circle(512, 540, 300, fill=rgba("#FFFFFF", 70)), "#FFFFFF", blur=60)
    calendar_glyph(full)
    full.save("app_icon.png", ICON_OUT)

    fg = Canvas.transparent((1024, 1024))
    calendar_glyph(fg)
    fg.save("app_icon_foreground.png", ICON_OUT)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for draw in (flutter_workshop, ai_panel, photography_exhibition, choir_concert,
                 basketball_final, campus_run, app_icon):
        draw()
