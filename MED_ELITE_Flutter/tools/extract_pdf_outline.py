#!/usr/bin/env python3
"""Extract only PDF bookmark/outline titles. No body text or OCR is indexed."""
import argparse
import json
from pathlib import Path
from urllib.parse import urlparse


def extract_outline(pdf_path: Path) -> list[str]:
    try:
        import fitz
    except ImportError as exc:
        raise SystemExit('Instala PyMuPDF: python -m pip install pymupdf') from exc
    with fitz.open(pdf_path) as doc:
        return list(dict.fromkeys(
            title.strip() for _level, title, _page in doc.get_toc(simple=True)
            if title and title.strip()
        ))


def main():
    parser=argparse.ArgumentParser(description='Indexar títulos de marcadores del PDF, no su contenido.')
    parser.add_argument('--pdf',required=True,type=Path,help='PDF autorizado almacenado localmente')
    parser.add_argument('--subject-id',required=True,type=int)
    parser.add_argument('--topic-id',required=True,type=int)
    parser.add_argument('--url',required=True,help='URL HTTPS autorizada del recurso remoto')
    parser.add_argument('--title',required=True,help='Título del libro')
    parser.add_argument('--subtitle',default='')
    parser.add_argument('--output',required=True,type=Path)
    args=parser.parse_args()
    u=urlparse(args.url)
    if u.scheme!='https' or not u.netloc:
        parser.error('Se exige URL HTTPS válida')
    headings=extract_outline(args.pdf)
    if not headings:
        parser.error('El PDF no contiene marcadores/índice digital. Registra capítulos manualmente o mediante CSV.')
    resource={'id':f'pdf_outline_{args.subject_id}_{args.topic_id}',
        'subjectId':args.subject_id,'topicId':args.topic_id,'title':args.title,
        'subtitle':args.subtitle,'headings':headings,'url':args.url,
        'category':'Libros oficiales y bibliografía','kind':'drive','access':'free',
        'source':'PDF autorizado; solo índice de marcadores',
        'note':'Los títulos se extrajeron de los marcadores del PDF; no se indexó el texto interior.'}
    args.output.write_text(json.dumps([resource],ensure_ascii=False,indent=2),encoding='utf-8')
    print(f'Extraídos {len(headings)} títulos de capítulos/marcadores → {args.output}')

if __name__=='__main__':main()
