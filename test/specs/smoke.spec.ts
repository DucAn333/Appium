import assert from 'node:assert/strict';
import { browser } from '@wdio/globals';

describe('Android smoke test', () => {
  it('opens the configured application and returns its UI', async () => {
    const source = await browser.getPageSource();
    assert.ok(source.includes('<'), 'Expected an XML UI hierarchy from Android');
  });
});
