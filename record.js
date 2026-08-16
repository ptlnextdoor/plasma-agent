// Records the live Plasma Treatment Agent demo to a video file.
// Drives the real deployed page so the footage is the actual product.
const { chromium } = require("playwright");

const URL = "https://plasma-agent.aayu22809-6c9.workers.dev";

// On-screen caption overlay so the video narrates itself (no voice needed).
async function caption(page, text, ms) {
  await page.evaluate((t) => {
    let el = document.getElementById("__cap");
    if (!el) {
      el = document.createElement("div");
      el.id = "__cap";
      el.style.cssText =
        "position:fixed;left:0;right:0;bottom:0;z-index:99999;padding:16px 22px;" +
        "background:rgba(3,8,14,.92);color:#e6edf3;font:600 18px/1.4 ui-monospace,Menlo,monospace;" +
        "border-top:2px solid #37d6a0;text-align:center";
      document.body.appendChild(el);
    }
    el.textContent = t;
  }, text);
  await page.waitForTimeout(ms);
}

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    recordVideo: { dir: "video-raw", size: { width: 1280, height: 800 } },
  });
  const page = await context.newPage();

  await page.goto(URL, { waitUntil: "networkidle" });
  // Clean slate.
  await page.evaluate((u) => fetch(u + "/api/reset"), URL);
  await page.reload({ waitUntil: "networkidle" });

  await caption(page, "Plasma Treatment Agent — cold-plasma wound therapy as a hibernating cloud agent", 4500);
  await caption(page, "Problem: plasma heats tissue toward a 40 C cutoff. The arm MUST pause between passes.", 5000);
  await caption(page, "Naive agents burn a warm instance polling a sensor through that wait. We hibernate instead.", 5000);

  // Start the treatment.
  await caption(page, "Click Start treatment ->", 1500);
  await page.click("text=Start treatment");
  await caption(page, "Pass 1 executes: coverage climbs, tissue temp rises.", 4000);
  await caption(page, "Now it HIBERNATES: instance evicted, no polling. An alarm is scheduled for the cool-down.", 6000);
  await caption(page, "Alarm wakes it in ~1 ms. Tissue cooled. Next pass runs. State survived hibernation.", 6000);
  await caption(page, "execute -> hibernate -> wake -> continue, autonomously, pass after pass.", 6000);

  // Let the loop run to completion (6 passes * 8s dwell ~ 48s). Poll status.
  let done = false;
  for (let i = 0; i < 16 && !done; i++) {
    const s = await page.evaluate((u) => fetch(u + "/api/status").then((r) => r.json()), URL);
    if (s.status === "complete") done = true;
    await caption(
      page,
      `Coverage ${Math.round((s.pass / (s.total || 6)) * 100)}%  ·  hibernations ${s.hibernations || 0}  ·  wake ${s.last_wake_latency_ms ?? "-"} ms  ·  idle cost avoided $${(s.idle_cost_saved || 0).toFixed(6)}`,
      3000
    );
  }

  await caption(page, "Complete. ~99.9% cost saved vs a warm instance held up through every dwell.", 5000);
  await caption(page, "Maps 1:1 to Alibaba FC Sandbox deep hibernation. Live: plasma-agent.aayu22809-6c9.workers.dev", 6000);
  await caption(page, "Built by Aayushya Patel · real 6-DOF DBD plasma hardware · IEEE ISEC 2026", 5000);

  await context.close(); // finalizes the video
  await browser.close();
  console.log("done recording");
})();
