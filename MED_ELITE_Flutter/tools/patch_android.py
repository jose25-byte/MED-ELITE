#!/usr/bin/env python3
"""Add INTERNET permission to generated Android main manifest for live search/WebViews."""
from pathlib import Path
p=Path('android/app/src/main/AndroidManifest.xml')
if not p.exists():
    raise SystemExit('Falta AndroidManifest.xml. Ejecuta primero: flutter create --platforms=android,ios .')
s=p.read_text(encoding='utf-8')
permission='<uses-permission android:name="android.permission.INTERNET" />'
if permission not in s:
    start=s.find('>')
    if start<0:
        raise SystemExit('No se reconoce el manifiesto Android.')
    s=s[:start+1]+'\n    '+permission+s[start+1:]
    p.write_text(s,encoding='utf-8')
print('Permiso INTERNET verificado.')
