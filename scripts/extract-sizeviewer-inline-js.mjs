import fs from 'node:fs';

const html = fs.readFileSync(new URL('../www/sizeviewer/index.html', import.meta.url), 'utf8');
const match = html.match(/<script>([\s\S]*)<\/script>/);

if (!match) {
  console.error('No inline <script> block found in www/sizeviewer/index.html');
  process.exit(1);
}

process.stdout.write(match[1].trimStart());
