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
    QDialog,
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
    font-family: "Terminus", "Noto Sans CJK JP";
    font-size: 13px;
}
QMainWindow, QDialog { background: #15101F; }
QFrame#shell {
    background: #D8CDD9;
    border: 2px solid #15101F;
}
QFrame#titlebar {
    background: #C82E91;
    border: 2px solid #15101F;
}
QLabel#title {
    background: transparent;
    color: #FFF3FF;
    font-family: "Terminus";
    font-size: 15px;
    font-weight: 700;
}
QFrame#menubar, QFrame#statusbar {
    background: #B7A7BC;
    border-top: 2px solid #FFF3FF;
    border-left: 2px solid #FFF3FF;
    border-right: 2px solid #56445E;
    border-bottom: 2px solid #56445E;
}
QFrame#page, QFrame#card, QFrame#nav {
    background: #F3EAF4;
    border-top: 2px solid #FFF9FF;
    border-left: 2px solid #FFF9FF;
    border-right: 2px solid #56445E;
    border-bottom: 2px solid #56445E;
}
QFrame#screen {
    background: #15101F;
    border: 2px solid #56445E;
}
QPushButton {
    min-height: 30px;
    padding: 3px 10px;
    background: #D8CDD9;
    border-top: 2px solid #FFF3FF;
    border-left: 2px solid #FFF3FF;
    border-right: 2px solid #56445E;
    border-bottom: 2px solid #56445E;
    font-family: "Terminus", "Noto Sans CJK JP";
    font-weight: 700;
}
QPushButton:hover { background: #F3EAF4; color: #8F276F; }
QPushButton:pressed {
    background: #B7A7BC;
    border-top: 2px solid #56445E;
    border-left: 2px solid #56445E;
    border-right: 2px solid #FFF3FF;
    border-bottom: 2px solid #FFF3FF;
}
QPushButton#accent { background: #C82E91; color: #FFF3FF; }
QPushButton#nav { text-align: left; min-height: 34px; }
QPushButton#menu {
    background: transparent;
    border: 0;
    min-height: 22px;
    padding: 1px 8px;
}
QPushButton#module { text-align: left; min-height: 54px; }
QLabel#heading {
    color: #201727;
    font-family: "Terminus";
    font-size: 20px;
    font-weight: 700;
}
QLabel#metric { color: #8F276F; font-size: 17px; font-weight: 700; }
QLabel#muted { color: #56445E; }
QLabel#signal { color: #62DDE4; background: transparent; font-weight: 700; }
QLabel#screenText {
    background: transparent;
    color: #FFF3FF;
    font-family: "Terminus";
    font-size: 14px;
    font-weight: 700;
}
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
    if not root.exists():
        return total, files, False
    for base, _, names in os.walk(root, onerror=lambda _: None):
        for name in names:
            files += 1
            if files > limit:
                return total, files - 1, True
            try:
                total += (Path(base) / name).stat().st_size
            except OSError:
                pass
    return total, files, False


class Page(QFrame):
    """Square Win9x page surface with a compact heading strip."""

    def __init__(self, heading: str, subtitle: str):
        super().__init__()
        self.setObjectName("page")
        self.layout = QVBoxLayout(self)
        self.layout.setContentsMargins(18, 16, 18, 16)
        self.layout.setSpacing(11)
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
        layout.setContentsMargins(14, 12, 14, 12)
        layout.setSpacing(8)
        self.layout.addWidget(frame)
        return frame, layout


class WelcomeDialog(QDialog):
    """First-login hand-off matching the approved desktop concept."""

    def __init__(self):
        super().__init__()
        self.setWindowTitle("MARISHOKU/OS システム")
        self.setFixedSize(540, 282)
        self.setWindowFlag(Qt.WindowType.WindowStaysOnTopHint, True)
        self.setStyleSheet(APP_STYLE)

        shell = QFrame()
        shell.setObjectName("shell")
        shell_layout = QVBoxLayout(shell)
        shell_layout.setContentsMargins(8, 8, 8, 8)
        shell_layout.setSpacing(8)

        titlebar = QFrame()
        titlebar.setObjectName("titlebar")
        title_layout = QHBoxLayout(titlebar)
        title_layout.setContentsMargins(10, 5, 10, 5)
        title = QLabel("♥  MARISHOKU/OS // SYSTEM")
        title.setObjectName("title")
        title_layout.addWidget(title)
        title_layout.addStretch()
        title_layout.addWidget(QLabel("MR-10"))
        shell_layout.addWidget(titlebar)

        content = QHBoxLayout()
        content.setContentsMargins(18, 10, 18, 4)
        content.setSpacing(26)
        mark = QLabel("♥")
        mark.setAlignment(Qt.AlignmentFlag.AlignCenter)
        mark.setFixedSize(100, 100)
        mark.setStyleSheet(
            "font-family: 'Terminus'; font-size: 70px; font-weight: 700; "
            "color: #D63BAC; background: transparent;"
        )
        content.addWidget(mark)

        copy = QVBoxLayout()
        copy.setSpacing(6)
        ready = QLabel("SYSTEM READY.")
        ready.setObjectName("heading")
        profile = QLabel(f"PROFILE:  {current_profile()}")
        profile.setObjectName("metric")
        signal = QLabel("ECLIPXSE LINK // JP INPUT READY")
        signal.setObjectName("muted")
        copy.addStretch()
        copy.addWidget(ready)
        copy.addWidget(profile)
        copy.addWidget(signal)
        copy.addStretch()
        content.addLayout(copy, 1)
        shell_layout.addLayout(content)

        enter = QPushButton("ENTER")
        enter.setObjectName("accent")
        enter.setFixedSize(180, 42)
        enter.clicked.connect(self.accept)
        shell_layout.addWidget(enter, 0, Qt.AlignmentFlag.AlignHCenter)

        outer = QVBoxLayout(self)
        outer.setContentsMargins(4, 4, 4, 4)
        outer.addWidget(shell)


class Center(QMainWindow):
    PAGES = ("HOME", "HARDWARE", "PROFILES", "STORAGE", "JAPANESE", "ABOUT")

    def __init__(self, initial_page: str):
        super().__init__()
        self.setWindowTitle("MARISHOKU CONTROL.EXE")
        self.resize(960, 650)
        self.setMinimumSize(820, 570)
        self.setStyleSheet(APP_STYLE)

        shell = QFrame()
        shell.setObjectName("shell")
        shell_layout = QVBoxLayout(shell)
        shell_layout.setContentsMargins(7, 7, 7, 7)
        shell_layout.setSpacing(7)

        titlebar = QFrame()
        titlebar.setObjectName("titlebar")
        title_layout = QHBoxLayout(titlebar)
        title_layout.setContentsMargins(11, 5, 8, 5)
        title = QLabel("♥  MARISHOKU CONTROL.EXE")
        title.setObjectName("title")
        title_layout.addWidget(title)
        title_layout.addStretch()
        profile = QLabel(f"PROFILE: {current_profile()}  //  V1.3")
        profile.setObjectName("title")
        title_layout.addWidget(profile)
        shell_layout.addWidget(titlebar)

        menubar = QFrame()
        menubar.setObjectName("menubar")
        menu_layout = QHBoxLayout(menubar)
        menu_layout.setContentsMargins(3, 1, 3, 1)
        menu_layout.setSpacing(0)
        for label, callback in (
            ("FILE", self.close),
            ("SYSTEM", lambda: self.stack.setCurrentIndex(1)),
            ("PROFILE", lambda: self.stack.setCurrentIndex(2)),
            ("HELP", lambda: self.stack.setCurrentIndex(5)),
        ):
            button = QPushButton(label)
            button.setObjectName("menu")
            button.clicked.connect(callback)
            menu_layout.addWidget(button)
        menu_layout.addStretch()
        shell_layout.addWidget(menubar)

        body = QHBoxLayout()
        body.setSpacing(7)
        nav = QFrame()
        nav.setObjectName("nav")
        nav.setFixedWidth(190)
        nav_layout = QVBoxLayout(nav)
        nav_layout.setContentsMargins(9, 9, 9, 9)
        nav_layout.setSpacing(6)

        identity = QFrame()
        identity.setObjectName("screen")
        identity_layout = QVBoxLayout(identity)
        identity_layout.setContentsMargins(11, 10, 11, 10)
        name = QLabel("魔理蝕 // MR-10")
        name.setObjectName("screenText")
        name.setAlignment(Qt.AlignmentFlag.AlignCenter)
        state = QLabel("● SYSTEM ONLINE")
        state.setObjectName("signal")
        state.setAlignment(Qt.AlignmentFlag.AlignCenter)
        identity_layout.addWidget(name)
        identity_layout.addWidget(state)
        nav_layout.addWidget(identity)

        self.stack = QStackedWidget()
        self.pages = {
            "HOME": self.home_page(),
            "HARDWARE": self.hardware_page(),
            "PROFILES": self.profile_page(),
            "STORAGE": self.storage_page(),
            "JAPANESE": self.japanese_page(),
            "ABOUT": self.about_page(),
        }
        for index, name in enumerate(self.PAGES):
            button = QPushButton(f"{index + 1:02d}  {name}")
            button.setObjectName("nav")
            button.clicked.connect(lambda _checked=False, i=index: self.stack.setCurrentIndex(i))
            nav_layout.addWidget(button)
            self.stack.addWidget(self.pages[name])
        nav_layout.addStretch()
        switch = QPushButton("SESSION...")
        switch.clicked.connect(self.open_session)
        nav_layout.addWidget(switch)

        body.addWidget(nav)
        body.addWidget(self.stack, 1)
        shell_layout.addLayout(body, 1)

        statusbar = QFrame()
        statusbar.setObjectName("statusbar")
        status_layout = QHBoxLayout(statusbar)
        status_layout.setContentsMargins(8, 2, 8, 2)
        status_layout.addWidget(QLabel("READY"))
        status_layout.addStretch()
        status_layout.addWidget(QLabel("裏 / URA · 日本語 INPUT · ECLIPXSE LINK OK"))
        shell_layout.addWidget(statusbar)

        outer = QWidget()
        outer_layout = QVBoxLayout(outer)
        outer_layout.setContentsMargins(5, 5, 5, 5)
        outer_layout.addWidget(shell)
        self.setCentralWidget(outer)
        self.stack.setCurrentIndex(self.PAGES.index(initial_page))

    def module_button(self, title: str, detail: str, module: str) -> QPushButton:
        button = QPushButton(f"{title}\n{detail}")
        button.setObjectName("module")
        button.clicked.connect(lambda: self.open_kcm(module))
        return button

    def home_page(self) -> Page:
        page = Page("SYSTEM READY.", "MARISHOKU is the shell. Debian and KDE remain the maintained hardware layer beneath it.")
        screen = QFrame()
        screen.setObjectName("screen")
        screen_layout = QVBoxLayout(screen)
        screen_layout.setContentsMargins(18, 16, 18, 16)
        line = QLabel("NO ONE IS COMING. PUSH ANYWAY.")
        line.setObjectName("screenText")
        line.setStyleSheet("color: #FF91D0; font-size: 18px;")
        screen_layout.addWidget(line)
        readout = QLabel(
            f"PROFILE........ {current_profile()}\n"
            f"HOST........... {platform.node() or 'UNKNOWN'}\n"
            "JAPANESE INPUT. READY\n"
            "SYSTEM LINK.... OK"
        )
        readout.setObjectName("screenText")
        readout.setStyleSheet("color: #62DDE4;")
        screen_layout.addWidget(readout)
        page.layout.addWidget(screen)

        grid = QGridLayout()
        grid.setSpacing(8)
        modules = (
            ("DISPLAY", "RESOLUTION / SCALE", "kcm_kscreen"),
            ("AUDIO", "OUTPUT / VOLUME", "kcm_pulseaudio"),
            ("NETWORK", "WI-FI / ETHERNET", "kcm_networkmanagement"),
            ("INPUT", "MOUSE / KEYBOARD", "kcm_keyboard"),
        )
        for index, (title, detail, module) in enumerate(modules):
            grid.addWidget(self.module_button(title, detail, module), index // 2, index % 2)
        page.layout.addLayout(grid)
        page.layout.addStretch()
        return page

    def hardware_page(self) -> Page:
        page = Page("SYSTEM LINK", "Read-only hardware summary with direct routes to maintained KDE modules.")
        _, layout = page.card()
        usage = shutil.disk_usage(Path.home())
        values = (
            ("OS", "MARISHOKU/OS V1.3 / Debian 13"),
            ("HOST", platform.node() or "unknown"),
            ("KERNEL", platform.release()),
            ("CPU", platform.processor() or platform.machine()),
            ("ARCH", platform.machine()),
            ("HOME FREE", human_size(usage.free)),
            ("PROFILE", current_profile()),
        )
        grid = QGridLayout()
        grid.setHorizontalSpacing(18)
        for row, (key, value) in enumerate(values):
            key_label = QLabel(key)
            key_label.setObjectName("muted")
            value_label = QLabel(value)
            value_label.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
            grid.addWidget(key_label, row, 0)
            grid.addWidget(value_label, row, 1)
        layout.addLayout(grid)

        buttons = QGridLayout()
        buttons.addWidget(self.module_button("BLUETOOTH", "DEVICES", "kcm_bluetooth"), 0, 0)
        buttons.addWidget(self.module_button("APPEARANCE", "KDE MODULES", "kcm_lookandfeel"), 0, 1)
        layout.addLayout(buttons)
        page.layout.addStretch()
        return page

    def profile_page(self) -> Page:
        page = Page("OMOTE // URA", "Switch the complete MARISHOKU mood without changing the underlying operating system.")
        for profile, title, detail in (
            ("omote", "OMOTE / 表", "Pearl panels, violet chrome, blossoms, and restrained daylight color."),
            ("ura", "URA / 裏", "Graphite night, hot-pink signal, cyan, rain, and cyber-goth diagnostics."),
        ):
            _, layout = page.card()
            label = QLabel(title)
            label.setObjectName("metric")
            layout.addWidget(label)
            detail_label = QLabel(detail)
            detail_label.setWordWrap(True)
            layout.addWidget(detail_label)
            button = QPushButton(f"APPLY {profile.upper()}")
            button.setObjectName("accent")
            button.clicked.connect(lambda _checked=False, p=profile: self.apply_profile(p))
            layout.addWidget(button)
        page.layout.addStretch()
        return page

    def storage_page(self) -> Page:
        page = Page("STORAGE CARE", "Safe preview only. MARISHOKU never deletes personal files or clears caches automatically.")
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
        warning = QLabel("REVIEW BEFORE REMOVING. Browser profiles and application state may contain data you still need.")
        warning.setWordWrap(True)
        warning.setObjectName("muted")
        layout.addWidget(warning)
        page.layout.addStretch()
        return page

    def japanese_page(self) -> Page:
        page = Page("JAPANESE INPUT / 日本語", "Fcitx 5 and Mozc provide optional Japanese input while your normal keyboard stays available.")
        screen = QFrame()
        screen.setObjectName("screen")
        screen_layout = QVBoxLayout(screen)
        screen_layout.setContentsMargins(18, 16, 18, 16)
        readout = QLabel("INPUT BUS...... FCITX 5\nENGINE......... MOZC\nTOGGLE......... CTRL + SPACE\nSTATE.......... READY")
        readout.setObjectName("screenText")
        screen_layout.addWidget(readout)
        page.layout.addWidget(screen)
        _, layout = page.card()
        text = QLabel("1. Open the configuration below.\n2. Confirm Mozc is listed after your normal keyboard.\n3. Switch input with Ctrl+Space.\n4. Click the taskbar JP status to return here.")
        text.setWordWrap(True)
        layout.addWidget(text)
        configure = QPushButton("OPEN FCITX CONFIGURATION")
        configure.setObjectName("accent")
        configure.clicked.connect(self.open_fcitx)
        layout.addWidget(configure)
        page.layout.addStretch()
        return page

    def about_page(self) -> Page:
        page = Page("ABOUT MR-10", "A Debian-based operating-system identity designed by Eclipxse.")
        screen = QFrame()
        screen.setObjectName("screen")
        layout = QVBoxLayout(screen)
        layout.setContentsMargins(18, 16, 18, 16)
        about = QLabel(
            "魔理蝕 // MARISHOKU/OS\n"
            "VERSION 1.3.0 DEV\n"
            "PROFILE URA / 裏 // MR-10\n\n"
            "BASE..... DEBIAN 13 TRIXIE\n"
            "DESKTOP.. KDE PLASMA 6 / WAYLAND\n"
            "SHELL.... MARISHOKU PIXEL SYSTEM\n\n"
            "NO ONE IS COMING. PUSH ANYWAY."
        )
        about.setObjectName("screenText")
        about.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
        layout.addWidget(about)
        page.layout.addWidget(screen)
        page.layout.addStretch()
        return page

    def open_kcm(self, module: str) -> None:
        for command in (("systemsettings", module), ("kcmshell6", module)):
            if shutil.which(command[0]):
                subprocess.Popen(command, start_new_session=True)
                return
        QMessageBox.warning(self, "MODULE NOT FOUND", f"Could not open KDE module: {module}")

    def open_fcitx(self) -> None:
        executable = shutil.which("fcitx5-config-qt")
        if executable:
            subprocess.Popen([executable], start_new_session=True)
        else:
            QMessageBox.warning(self, "INPUT MODULE NOT FOUND", "Install fcitx5-config-qt and try again.")

    def open_session(self) -> None:
        executable = shutil.which("qdbus6") or shutil.which("qdbus")
        if executable:
            subprocess.Popen(
                [executable, "org.kde.LogoutPrompt", "/LogoutPrompt", "promptAll"],
                start_new_session=True,
            )
        else:
            QMessageBox.warning(self, "SESSION LINK FAILED", "The KDE session service is unavailable.")

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
    parser.add_argument(
        "--page",
        choices=("welcome", "home", "system", "hardware", "profiles", "storage", "japanese", "about"),
        default="home",
    )
    args = parser.parse_args()
    app = QApplication(sys.argv)
    app.setApplicationName("MARISHOKU Control Center")
    app.setFont(QFont("Terminus", 11))
    if args.page == "welcome":
        return WelcomeDialog().exec()

    page_alias = {"system": "HARDWARE"}
    window = Center(page_alias.get(args.page, args.page.upper()))
    window.show()
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
