from distutils.core import setup
setup(name='BITONspendfrom',
      version='1.0',
      description='Command-line utility for biton "coin control"',
      author='Gavin Andresen',
      author_email='gavin@bitonfoundation.org',
      requires=['jsonrpc'],
      scripts=['spendfrom.py'],
      )
