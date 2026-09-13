#!/usr/bin/env python3
import sys
import subprocess
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

QS_PATH = "/home/zen/.config/quickshell/dynamic-island"

DBusGMainLoop(set_as_default=True)

class NotificationServer(dbus.service.Object):
    def __init__(self, bus_name):
        super().__init__(bus_name, '/org/freedesktop/Notifications')
        self.id_counter = 1

    @dbus.service.method('org.freedesktop.Notifications', in_signature='susssasa{sv}i', out_signature='u')
    def Notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, timeout):
        summary_str = str(summary).replace('"', '\\"')
        body_str = str(body).replace('"', '\\"')
        app_str = str(app_name).replace('"', '\\"')
        
        print(f"Notification: {app_str} - {summary_str}")

        # Send IPC to quickshell
        subprocess.Popen([
            "quickshell", "ipc", "-p", QS_PATH, "call", "notification", 
            "showNotification", app_str, summary_str, body_str
        ])

        current_id = self.id_counter
        self.id_counter += 1
        return dbus.UInt32(current_id)

    @dbus.service.method('org.freedesktop.Notifications', in_signature='', out_signature='ssss')
    def GetServerInformation(self):
        return ("DynamicIsland", "zen", "1.0", "1.2")

    @dbus.service.method('org.freedesktop.Notifications', in_signature='', out_signature='as')
    def GetCapabilities(self):
        return dbus.Array(["body", "actions", "icon-static"], signature='s')

    @dbus.service.method('org.freedesktop.Notifications', in_signature='u', out_signature='')
    def CloseNotification(self, id):
        pass

bus = dbus.SessionBus()
name = dbus.service.BusName('org.freedesktop.Notifications', bus)
server = NotificationServer(name)

loop = GLib.MainLoop()
try:
    loop.run()
except KeyboardInterrupt:
    pass
