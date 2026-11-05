import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const base = new URL('../ui/', import.meta.url);
const [html, css, app, logo] = await Promise.all([
  readFile(new URL('index.html', base), 'utf8'),
  readFile(new URL('saint-servan-theme.css', base), 'utf8'),
  readFile(new URL('js/app.js', base), 'utf8'),
  readFile(new URL('saint-servan.svg', base), 'utf8'),
]);

test('the brand is opt-in at the HTML root and includes the stylesheet', () => {
  assert.match(html, /<html[^>]*data-brand="saint-servan"/);
  const orig = html.indexOf('href="styles.css"');
  const custom = html.indexOf('href="saint-servan-theme.css"');
  assert.ok(orig >= 0 && custom > orig);
});

test('Saint-Servan site palette is available in light and dark themes', () => {
  assert.match(css, /:root\[data-brand="saint-servan"\]/);
  assert.match(css, /:root\[data-brand="saint-servan"\]\[data-theme="light"\]/);
  for (const token of [
    '--bg', '--sidebar', '--surface', '--surface-2', '--text', '--muted',
    '--accent', '--accent-soft', '--focus', '--line', '--radius',
  ]) {
    assert.ok(css.includes(token + ':'), 'Missing token ' + token);
  }
  assert.match(css, /hsl\(231 100% 67%\)/);
  assert.match(css, /hsl\(231 100% 63%\)/);
  assert.match(css, /prefers-reduced-motion/);
});

test('desktop branding retains openOMSI identity and adds Saint-Servan icon', () => {
  assert.match(app, /<b>openOMSI<\/b>/);
  assert.match(app, /src="saint-servan.svg"/);
  assert.match(app, /class="brand-site">Saint-Servan/);
  assert.match(logo, /<svg[^>]*viewBox="0 0 512 512"/);
});

test('launcher Inter font stays active for desktop selftests', () => {
  assert.doesNotMatch(css, /font-family:\s*Arial/);
});
