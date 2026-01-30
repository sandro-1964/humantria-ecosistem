import { test, expect } from '@playwright/test'

test.describe('T7 Smoke', () => {
  test('TEST 1 — app carrega', async ({ page }) => {
    await page.goto('/')
    await expect(page).toHaveTitle(/humantria/i)
    await expect(page.getByRole('button', { name: /Entrar em DEMO/i })).toBeVisible({ timeout: 10_000 })
  })

  test('TEST 2 — DEMO login', async ({ page }) => {
    await page.goto('/')
    await page.getByRole('button', { name: /Entrar em DEMO/i }).click()
    await expect(page.getByRole('link', { name: /Core/i }).first()).toBeVisible({ timeout: 10_000 })
  })

  test('TEST 3 — menu visível', async ({ page }) => {
    await page.goto('/')
    await page.getByRole('button', { name: /Entrar em DEMO/i }).click()
    await expect(page.getByRole('link', { name: /Foundation/i }).first()).toBeVisible({ timeout: 10_000 })
    await expect(page.getByRole('link', { name: /Core/i }).first()).toBeVisible()
    await expect(page.getByRole('link', { name: /Strategy/i }).first()).toBeVisible()
  })

  test('TEST 4 — /core abre', async ({ page }) => {
    await page.goto('/')
    await page.getByRole('button', { name: /Entrar em DEMO/i }).click()
    await expect(page.getByRole('link', { name: /Core/i }).first()).toBeVisible({ timeout: 10_000 })
    await page.goto('/core')
    await expect(page.getByRole('heading', { name: 'Core', level: 1 })).toBeVisible({ timeout: 10_000 })
  })

  test('TEST 5 — /strategy abre', async ({ page }) => {
    await page.goto('/')
    await page.getByRole('button', { name: /Entrar em DEMO/i }).click()
    await expect(page.getByRole('link', { name: /Strategy/i }).first()).toBeVisible({ timeout: 10_000 })
    await page.goto('/strategy')
    await expect(page.getByRole('heading', { name: 'Strategy', level: 1 })).toBeVisible({ timeout: 10_000 })
  })

  test('TEST 6 — /__diag/meta retorna JSON válido (build + health)', async ({ page }) => {
    await page.goto('/__diag/meta')
    const pre = page.locator('pre').first()
    await expect(pre).toBeVisible({ timeout: 10_000 })
    const bodyText = await pre.textContent()
    expect(bodyText).toBeTruthy()
    const meta = JSON.parse(bodyText!) as { build?: { version?: string }; health?: { auth?: { status?: string } } }
    expect(meta.build?.version).toBeDefined()
    expect(meta.health?.auth?.status).toBeDefined()
  })

  test('TEST 7 — sem erro 500', async ({ page }) => {
    const badStatuses: number[] = []
    const consoleErrors: string[] = []
    page.on('response', (res) => {
      const status = res.status()
      if (status >= 500) badStatuses.push(status)
    })
    page.on('console', (msg) => {
      if (msg.type() === 'error') consoleErrors.push(msg.text())
    })

    await page.goto('/')
    await page.getByRole('button', { name: /Entrar em DEMO/i }).click()
    await expect(page.getByRole('link', { name: /Core/i }).first()).toBeVisible({ timeout: 10_000 })
    await page.goto('/core')
    await expect(page.getByRole('heading', { name: 'Core', level: 1 })).toBeVisible({ timeout: 10_000 })
    await page.goto('/strategy')
    await expect(page.getByRole('heading', { name: 'Strategy', level: 1 })).toBeVisible({ timeout: 10_000 })
    await page.goto('/__diag/meta')
    await expect(page.locator('pre').first()).toBeVisible({ timeout: 10_000 })

    expect(badStatuses, `Unexpected 5xx responses: ${badStatuses.join(', ')}`).toEqual([])
  })
})
