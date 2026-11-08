#!/usr/bin/env python3
"""Build link + chapter-heading catalog from authorized CSV metadata, never from PDF bodies."""
import csv
import json
import sys
from pathlib import Path
from urllib.parse import urlparse
REQUIRED=['id','subjectId','topicId','title','url']
DEFAULT_CATEGORY='Libros oficiales y bibliografía'

def import_file(src:Path,dest:Path):
    with src.open(newline='',encoding='utf-8-sig') as f:
        reader=csv.DictReader(f)
        if not reader.fieldnames or any(k not in reader.fieldnames for k in REQUIRED):
            raise ValueError(f'Columnas requeridas: {", ".join(REQUIRED)}')
        resources=[]
        for num,row in enumerate(reader,2):
            if not any((v or '').strip() for v in row.values()):continue
            url=(row.get('url') or '').strip()
            if urlparse(url).scheme!='https' or not urlparse(url).netloc:
                raise ValueError(f'Fila {num}: URL HTTPS requerida')
            item={
                'id':row['id'].strip(),'subjectId':int(row['subjectId']),
                'topicId':int(row['topicId']), 'title':row['title'].strip(),
                'subtitle':(row.get('subtitle') or '').strip(),
                'headings':[x.strip() for x in (row.get('headings') or '').split('|') if x.strip()],
                'url':url,'category':(row.get('category') or DEFAULT_CATEGORY).strip(),
                'kind':(row.get('kind') or 'drive').strip(),
                'access':(row.get('access') or 'free').strip(),
                'source':(row.get('source') or 'Metadatos autorizados').strip(),
                'note':'Importado de índice editorial o proporcionado por el administrador; no se descargó el libro.'
            }
            resources.append(item)
    dest.write_text(json.dumps(resources,ensure_ascii=False,indent=2),encoding='utf-8')
    print(f'{len(resources)} recursos indexados → {dest}')

if __name__=='__main__':
    if len(sys.argv)!=3:raise SystemExit('Uso: import_resources_csv.py origen.csv destino.json')
    import_file(Path(sys.argv[1]),Path(sys.argv[2]))
