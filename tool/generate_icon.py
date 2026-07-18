#!/usr/bin/env python3
"""Generates the Crux CZ launcher icon (pure stdlib, no PIL).

Outputs:
  assets/icon/app_icon.png            1024px, graphite background
  assets/icon/app_icon_foreground.png 1024px, transparent background,
                                      content shrunk to the adaptive-icon
                                      safe zone

Design: two signal-orange peaks (the brand's climbing motif) with a white
chalk dot, on the app's graphite surface.
"""

import struct
import zlib

SIZE = 1024
SS = 3  # supersampling factor

GRAPHITE_TOP = (0x2A, 0x32, 0x3D)
GRAPHITE_BOTTOM = (0x14, 0x18, 0x1E)
ORANGE = (0xE8, 0x57, 0x1F)
ORANGE_LIGHT = (0xF0, 0x7B, 0x4C)
WHITE = (0xF6, 0xF1, 0xEA)


def in_triangle(px, py, a, b, c):
    def sign(p1, p2, p3):
        return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1])

    d1 = sign((px, py), a, b)
    d2 = sign((px, py), b, c)
    d3 = sign((px, py), c, a)
    has_neg = d1 < 0 or d2 < 0 or d3 < 0
    has_pos = d1 > 0 or d2 > 0 or d3 > 0
    return not (has_neg and has_pos)


# Unit-space geometry (0..1). Kept within the central safe zone.
PEAK_BACK = ((0.38, 0.36), (0.12, 0.74), (0.64, 0.74))
PEAK_FRONT = ((0.62, 0.22), (0.32, 0.74), (0.92, 0.74))
DOT_CENTER = (0.24, 0.26)
DOT_RADIUS = 0.05


def shape_color(ux, uy):
    """Returns the foreground color at a unit-space point, or None."""
    dx = ux - DOT_CENTER[0]
    dy = uy - DOT_CENTER[1]
    if dx * dx + dy * dy <= DOT_RADIUS * DOT_RADIUS:
        return WHITE
    if in_triangle(ux, uy, *PEAK_FRONT):
        return ORANGE
    if in_triangle(ux, uy, *PEAK_BACK):
        return ORANGE_LIGHT
    return None


def render(with_background, content_scale):
    rows = []
    for y in range(SIZE):
        row = bytearray([0])  # PNG filter byte
        for x in range(SIZE):
            r = g = b = a = 0
            for sy in range(SS):
                for sx in range(SS):
                    ux = (x + (sx + 0.5) / SS) / SIZE
                    uy = (y + (sy + 0.5) / SS) / SIZE
                    # Scale content around the icon center.
                    cx = 0.5 + (ux - 0.5) / content_scale
                    cy = 0.5 + (uy - 0.5) / content_scale
                    color = None
                    if 0 <= cx <= 1 and 0 <= cy <= 1:
                        color = shape_color(cx, cy)
                    if color is None:
                        if with_background:
                            t = uy
                            color = tuple(
                                round(GRAPHITE_TOP[i] * (1 - t) + GRAPHITE_BOTTOM[i] * t)
                                for i in range(3)
                            )
                        else:
                            continue
                    r += color[0]
                    g += color[1]
                    b += color[2]
                    a += 255
            n = SS * SS
            row += bytes((round(r / n), round(g / n), round(b / n), round(a / n)))
        rows.append(bytes(row))
    return b"".join(rows)


def write_png(path, raw):
    def chunk(tag, data):
        payload = tag + data
        return struct.pack(">I", len(data)) + payload + struct.pack(
            ">I", zlib.crc32(payload)
        )

    header = struct.pack(">IIBBBBB", SIZE, SIZE, 8, 6, 0, 0, 0)
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )
    with open(path, "wb") as f:
        f.write(png)
    print(f"wrote {path}")


write_png("assets/icon/app_icon.png", render(True, 1.0))
# Adaptive foreground: transparent, content shrunk into the ~66% safe zone.
write_png("assets/icon/app_icon_foreground.png", render(False, 0.62))
