# Plasma Treatment Agent — Hackathon Submission Kit

**LIVE URL (no login):** https://plasma-agent.aayu22809-6c9.workers.dev
**Repo:** local at desktop/melani/plasma-agent (push to github.com/ptlnextdoor if time)
**Team:** Aayushya Patel — aayu22809@gmail.com — 669.732.0048

---

## SHEET ROW (fill your row in the Ship the Next Submission Sheet)
- Team: Aayushya Patel (Kahlus / Roshni)
- Contact: aayu22809@gmail.com · 669.732.0048
- Product name: Plasma Treatment Agent
- Live URL: https://plasma-agent.aayu22809-6c9.workers.dev
- Demo video URL: <PASTE YOUR 3-MIN VIDEO LINK — YouTube unlisted / Loom / Drive>
- Slides/Repo: <Master Slides link once you add the 3 slides>

## ONE-SENTENCE DESCRIPTION (WHO + WHAT + WHY NOW)
For clinicians running cold-plasma wound therapy (WHO), the Plasma Treatment
Agent is a hibernating cloud control loop that runs each robotic raster pass
then sleeps through the mandatory thermal cool-down instead of burning a warm
instance polling a sensor (WHAT) — now that agent platforms bill for idle
compute, execute-wait-execute medical workflows only pencil out if the waiting
phase costs nothing (WHY NOW).

---

## 3 SLIDES (paste into Master Slides)

### Slide 1 — Team
- Aayushya Patel, 17. Two years building a 6-DOF DBD cold-plasma wound-treatment
  robot under Dr. Sohail Zaidi, San Jose State. IEEE ISEC 2026 (Princeton).
- Solo builder: control board (8,800-line KiCad, 6× TMC5160, Teensy 4.1),
  4-modality sensor head, depth→G-code path pipeline, <0.1 mm deviation.

### Slide 2 — Product
- Plasma Treatment Agent: the treatment workflow as a hibernating cloud agent.
- Real waiting phase: plasma heats tissue toward the 40 °C safety cutoff, so the
  arm must pause between passes for a cool-down dwell (~2 min in clinic).
- Instead of an idle instance polling the thermal sensor, the agent runs a pass,
  **hibernates** through the dwell (evicted, ~$0), and an alarm **wakes** it to
  run the next pass. Full loop: execute → hibernate → wake → continue.
- State persisted across hibernation; structured trace_id log per event.

### Slide 3 — Demo (embed video)
- Live URL, one click "Start treatment."
- Watch: 6 passes advance autonomously; status flips executing ↔ hibernating;
  wake latency ~1 ms; idle cost avoided ticks up (~99.9% vs warm instance).
- FC Sandbox mapping shown: pass=AgentRun tool call, dwell=deep hibernation,
  timer/thermal=external wake trigger, event log=SLS/Trace.

---

## 3-MIN DEMO SCRIPT (record this)
[0:00] "Cold-plasma wound therapy: a robot arm rasters plasma over a wound. My
        hardware does this — but plasma heats tissue toward a 40 °C cutoff, so
        between passes it MUST wait for a cool-down. That waiting is the problem."
[0:25] "On an agent platform you pay for idle compute. Polling a sensor for 2
        minutes per pass, across a full session, is pure waste. So I built the
        treatment loop as a hibernating cloud agent." (show live URL)
[0:50] Click Start. "Pass 1 executes — coverage 17%, temp climbs to 29 °C."
[1:05] "Now it hibernates. The instance is evicted from memory. It is NOT
        polling. An alarm is scheduled for the cool-down dwell." (point to
        HIBERNATE log line, status pill = hibernating)
[1:30] "Alarm fires, agent wakes in ~1 ms, tissue has cooled, pass 2 runs.
        State survived hibernation — same trace_id, pass counter advanced."
[2:00] "It repeats autonomously to 100% coverage. Watch idle-cost-avoided climb
        — ~99.9% saved versus keeping a warm instance up through every dwell."
[2:25] "This is exactly FC Sandbox's execute-wait-execute pattern: pass = an
        AgentRun tool call, dwell = deep hibernation, thermal event = external
        wake, and the structured event log is the Trace/SLS story. Proven here
        on Durable Object hibernation because I couldn't provision FC in an hour,
        but the loop maps 1:1."
[2:50] "Real hardware, real waiting phase, real cost model. Thank you."

## HONESTY NOTE (say it, judges reward it)
- 49% faster-healing figure is the published field literature, not my device.
- Cost numbers are a model of a warm-instance baseline, labeled as such in the UI.
- Loop runs on Cloudflare DO hibernation, not FC Sandbox — documented mapping.
