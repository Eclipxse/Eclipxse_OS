#!/usr/bin/env python3
"""MARISHOKU/OS Control Center and safe maintenance UI."""

from __future__ import annotations

import argparse
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

from PyQt6.QtCore import Qt, QUrl
from PyQt6.QtGui import QDesktopServices, QFont
from PyQt6.QtWidgets import (
    QApplication,
    QFrame,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QStackedWidget,
    QVBoxLayout,
    QWidget,
)


APP_STYLE = """
QWidget {
    background: #D8CDD9;
    color: #201727;
    font-family: "Noto Sans Mono";
    font-size: 13px;
}
QFrame#titlebar {
    background: #C82E91;
    border: 2px solid #201727;
}
QLabel#title {
    background: transparent;
    color: #FFF3FF;
    font-weight: 700;
    font-size: 15px;
}
QFrame#page, QFrame#card {
    background: #F3EAF4;
    border-top: 2px solid #FFF9FF;
    border-left: 2px solid #FFF9FF;
    border-right: 2px solid #56445E;
    border-bottom: 2px solid #56445E;
}
QPushButton {
    min-height: 36px;
    padding: 4px 12px;
    background: #D8CDD9;
    border-top: 2px solid #FFF3FF;
    border-left: 2px solid #FFF3FF;
    border-right: 2px solid #56445E;
    border-bottom: 2px solid #56445E;
    font-weight: 700;
}
QPushButton:hover { background: #E8D8E8; color: #8F276F; }
QPushButton:pressed {
    background: #C8B9CC;
    border-top: 2px solid #56445E;
    border-left: 2px solid #56445E;
    border-right: 2px solid #FFF3FF;
    border-bottom: 2px solid #FFF3FF;
}
QPushButton#accent { background: #C82E91; color: #FFF3FF; }
QLabel#heading { font-size: 22px; font-weight: 700; color: #7141C1; }
QLabel#metric { font-size: 18px; font-weight: 700; color: #8F276F; }
QLabel#muted { color: #56445E; }
"""


def human_size(value: int) -> str:
    size = float(value)
    for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
        if size < 1024 or unit == "TiB":
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} TiB"


def current_profile() -> str:
    path = Path.home() / ".config/marishoku/profile"
    return path.read_text(encoding="utf-8").strip().upper() if path.exists() else "URA"


def cache_estimate(limit: int = 30_000) -> tuple[int, int, bool]:
    root = Path.home() / ".cache"
    total = 0
    files = 0
    truncated = False
    if not root.exists():
        return total, files, truncated
    for base, _, names in os.walk(root, onerror=lambda _: None):
        for name in names:
            files += 1
            if files > limit:
                truncated = True
                return total, files - 1, truncated
            try:
                total += (Path(base) / name).stat().st_size
            except OSError:
                pass
    return total, files, truncated


class Page(QFrame):
    def __init__(self, heading: str, subtitle: str):
        super().__init__()
        self.setObjectName("page")
        self.layout = QVBoxLayout(self)
        self.layout.setContentsMargins(28, 24, 28, 24)
        self.layout.setSpacing(16)
        title = QLabel(heading)
        title.setObjectName("heading")
        self.layout.addWidget(title)
        note = QLabel(subtitle)
        note.setObjectName("muted")
        note.setWordWrap(True)
        self.layout.addWidget(note)

    def card(self) -> tuple[QFrame, QVBoxLayout]:
        frame = QFrame()
        frame.setObjectName("card")
        layout = QVBoxLayout(frame)
        layout.setContentsMargins(18, 16, 18, 16)
        layout.setSpacing(9)
        self.layout.addWidget(frame)
        return frame, layout


class Center(QMainWindow):
    PAGES = ("WELCOME", "SYSTEM", "PROFILES", "STORAGE", "JAPANESE", "ABOUT")

    def __init__(self, initial_page: str):
        super().__init__()
        self.setWindowTitle("MARISHOKU/OS CONTROL CENTER")
        self.resize(980, 680)
        self.setMinimumSize(820, 580)
        self.setStyleSheet(APP_STYLE)

        outer = QWidget()
        outer_layout = QVBoxLayout(outer)
        outer_layout.setContentsMargins(8, 8, 8, 8)
        outer_layout.setSpacing(8)

        titlebar = QFrame()
        titlebar.setObjectName("titlebar")
        title_layout = QHBoxLayout(titlebar)
        title_layout.setContentsMargins(12, 7, 12, 7)
        title = QLabel("♥  MARISHOKU/OS // CONTROL CENTER")
        title.setObjectName("title")
        title_layout.addWidget(title)
        title_layout.addStretch()
        profile = QLabel(f"PROFILE: {current_profile()}")
        profile.setObjectName("title")
        title_layout.addWidget(profile)
        outer_layout.addWidget(titlebar)

        body = QHBoxLayout()
        body.setSpacing(8)
        nav = QFrame()
        nav.setObjectName("card")
        nav.setFixedWidth(190)
        nav_layout = QVBoxLayout(nav)
        nav_layout.setContentsMargins(10, 10, 10, 10)
        nav_layout.setSpacing(8)

        self.stack = QStackedWidget()
        self.pages = {
            "WELCOME": self.welcome_page(),
            "SYSTEM": self.system_page(),
            "PROFILES": self.profile_page(),
            "STORAGE": self.storage_page(),
            "JAPANESE": self.japanese_page(),
            "ABOUT": self.about_page(),
        }
        for index, name in enumerate(self.PAGES):
            button = QPushButton(name)
            button.clicked.connect(lambda _checked=False, i=index: self.stack.setCurrentIndex(i))
            nav_layout.addWidget(button)
            self.stack.addWidget(self.pages[name])
        nav_layout.addStretch()

        body.addWidget(nav)
        body.addWidget(self.stack, 1)
        outer_layout.addLayout(body, 1)
        self.setCentralWidget(outer)
        self.stack.setCurrentIndex(self.PAGES.index(initial_page))

    def welcome_page(self) -> Page:
        page = Page("SYSTEM READY.", "Welcome to a clean Japanese Y2K pixel desktop. Nothing here is baked into the wallpaper; every window is real.")
        _, layout = page.card()
        message = QLabel("YOU ARE STILL HERE.\nTHAT COUNTS.\n\nChoose OMOTE for the pearl daytime profile or URA for the after-dark profile.")
        message.setObjectName("metric")
        message.setWordWrap(True)
        layout.addWidget(message)
        row = QHBoxLayout()
        omote = QPushButton("APPLY OMOTE / 表")
        ura = QPushButton("APPLY URA / 裏")
        omote.clicked.connect(lambda: self.apply_profile("omote"))
        ura.clicked.connect(lambda: self.apply_profile("ura"))
        row.addWidget(omote)
        row.addWidget(ura)
        layout.addLayout(row)
        page.layout.addStretch()
        return page

    def system_page(self) -> Page:
        page = Page("SYSTEM LINK", "Read-only hardware and session summary.")
        _, layout = page.card()
        usage = shutil.disk_usage(Path.home())
        values = (
            ("OS", "MARISHOKU/OS V1 (Debian 13 base)"),
            ("HOST", platform.node() or "unknown"),
            ("KERNEL", platform.release()),
            ("CPU", platform.processor() or platform.machine()),
            ("ARCH", platform.machine()),
            ("HOME FREE", human_size(usage.free)),
            ("PROFILE", current_profile()),
        )
        grid = QGridLayout()
        for row, (key, value) in enumerate(values):
            key_label = QLabel(key)
            key_label.setObjectName("muted")
            value_label = QLabel(value)
            value_label.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
            grid.addWidget(key_label, row, 0)
            grid.addWidget(value_label, row, 1)
        layout.addLayout(grid)
        page.layout.addStretch()
        return page

    def profile_page(self) -> Page:
        page = Page("OMOTE // URA", "Profiles change palette, wallpaper, lock image, and content level as one transaction.")
        for profile, title, detail in (
            ("omote", "OMOTE / 表", "Pearl panels, violet chrome, blossoms, and Momo/Kuro."),
            ("ura", "URA / 裏", "Graphite night, hot pink signal, cyan, and heart-eye diagnostics."),
        ):
            _, layout = page.card()
            label = QLabel(title)
            label.setObjectName("metric")
            layout.addWidget(label)
            layout.addWidget(QLabel(detail))
            button = QPushButton(f"APPLY {profile.upper()}")
            button.setObjectName("accent")
            button.clicked.connect(lambda _checked=False, p=profile: self.apply_profile(p))
            layout.addWidget(button)
        page.layout.addStretch()
        return page

    def storage_page(self) -> Page:
        page = Page("STORAGE CARE", "Safe preview only. V1 never deletes files or clears caches automatically.")
        _, layout = page.card()
        self.storage_metric = QLabel("PRESS REFRESH TO SCAN ~/.cache")
        self.storage_metric.setObjectName("metric")
        layout.addWidget(self.storage_metric)
        row = QHBoxLayout()
        refresh = QPushButton("REFRESH SCAN")
        open_cache = QPushButton("OPEN CACHE FOLDER")
        refresh.clicked.connect(self.refresh_storage)
        open_cache.clicked.connect(lambda: QDesktopServices.openUrl(QUrl.fromLocalFile(str(Path.home() / ".cache"))))
        row.addWidget(refresh)
        row.addWidget(open_cache)
        layout.addLayout(row)
        warning = QLabel("Review files yourself. Package caches, browser profiles, and application state can contain data you still need.")
        warning.setWordWrap(True)
        warning.setObjectName("muted")
        layout.addWidget(warning)
        page.layout.addStretch()
        return page

    def japanese_page(self) -> Page:
        page = Page("JAPANESE INPUT / 日本語", "Fcitx 5 + Mozc is included as an optional input method.")
        _, layout = page.card()
        text = QLabel("1. Click the keyboard/input icon in the tray.\n2. Add Mozc if it is not already listed.\n3. Switch with Ctrl+Space.\n\nYour normal keyboard layout remains the default.")
        text.setWordWrap(True)
        layout.addWidget(text)
        configure = QPushButton("OPEN FCITX CONFIGURATION")
        configure.clicked.connect(lambda: subprocess.Popen(["fcitx5-config-qt"], start_new_session=True))
        layout.addWidget(configure)
        page.layout.addStretch()
        return page

    def about_page(self) -> Page:
        page = Page("ABOUT MR-10", "A Debian-based operating system identity by Eclipxse.")
        _, layout = page.card()
        about = QLabel("魔理蝕 // MARISHOKU/OS\nVERSION 1.0.0 DEV\nBASE: DEBIAN 13 TRIXIE\nDESKTOP: KDE PLASMA 6 / WAYLAND\n\nOriginal deterministic artwork. No mood-board images are redistributed.")
        about.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
        about.setWordWrap(True)
        layout.addWidget(about)
        page.layout.addStretch()
        return page

    def apply_profile(self, profile: str) -> None:
        result = subprocess.run(["marishoku-profile", profile], capture_output=True, text=True, check=False)
        if result.returncode == 0:
            QMessageBox.information(self, "PROFILE READY", result.stdout.strip())
        else:
            QMessageBox.critical(self, "PROFILE ERROR", result.stderr.strip() or "Profile switch failed.")

    def refresh_storage(self) -> None:
        total, files, truncated = cache_estimate()
        suffix = " (FIRST 30,000 FILES)" if truncated else ""
        self.storage_metric.setText(f"CACHE PREVIEW: {human_size(total)} // {files:,} FILES{suffix}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--page", choices=("welcome", "system", "profiles", "storage", "japanese", "about"), default="system")
    args = parser.parse_args()
    app = QApplication(sys.argv)
    app.setApplicationName("MARISHOKU Control Center")
    app.setFont(QFont("Noto Sans Mono", 10))
    window = Center(args.page.upper())
    window.show()
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
