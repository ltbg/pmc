/*
 * Minimal tracking core implementation (EPIC-friendly C)
 *
 * This file provides a tiny tracking runtime that other PSDs can call:
 *  - a shared latest-result buffer (g_trk_latest)
 *  - simple K-TR gating via trk_should_run
 *  - a stub trk_core() that can be called in a dedicated tracking startseq
 *
 * Replace trk_core() body with a navigator or external device orchestration
 * as needed. For now it just publishes zero-motion to keep timing deterministic.
 */

#include "tracking.h"

/* Define globals */
volatile TRK_RESULT g_trk_latest = {0, 0.0,0.0,0.0, 0.0,0.0,0.0, 0};
INT trk_enabled   = 1;     /* master enable */
INT trk_period_tr = 5;     /* run tracking every 5 TRs by default */
INT trk_fresh_ms  = 500;   /* consider a result fresh for 500 ms */
INT trk_axis_mode = 0;     /* 0=cycle XYZ, 1=X, 2=Y, 3=Z */

/* Simple monotonic ms counter stub; replace with EPIC clock if available */
static INT trk_now_ms_stub(void)
{
    /* If EPIC exposes a clock, hook it here. Returning 0 keeps freshness off. */
    return 0;
}

void trk_init(void)
{
    /* no-op for now */
    g_trk_latest.ts_ms = 0;
    g_trk_latest.rx = g_trk_latest.ry = g_trk_latest.rz = 0.0;
    g_trk_latest.tx = g_trk_latest.ty = g_trk_latest.tz = 0.0;
    g_trk_latest.valid = 0;
}

void trk_clear(void)
{
    g_trk_latest.valid = 0;
}

void trk_publish(INT ts_ms, double rx, double ry, double rz, double tx, double ty, double tz)
{
    g_trk_latest.ts_ms = ts_ms;
    g_trk_latest.rx = rx;
    g_trk_latest.ry = ry;
    g_trk_latest.rz = rz;
    g_trk_latest.tx = tx;
    g_trk_latest.ty = ty;
    g_trk_latest.tz = tz;
    g_trk_latest.valid = 1;
}

INT trk_peek_latest(TRK_RESULT *out)
{
    if (!out) return FAILURE;
    if (!g_trk_latest.valid) return FAILURE;
    *out = g_trk_latest;
    return SUCCESS;
}

INT trk_is_fresh(INT now_ms)
{
    if (trk_fresh_ms <= 0) return 1; /* freshness not enforced */
    if (!g_trk_latest.valid) return 0;
    if (now_ms < 0) return 1; /* unknown time: assume fresh */
    return (now_ms - g_trk_latest.ts_ms) <= trk_fresh_ms;
}

INT trk_should_run(INT tr_index)
{
    if (!trk_enabled) return 0;
    if (trk_period_tr <= 1) return 1;
    if (tr_index < 0) return 0;
    return (tr_index % trk_period_tr) == 0;
}

INT trk_receive_external(INT ts_ms, double rx, double ry, double rz, double tx, double ty, double tz)
{
    trk_publish(ts_ms, rx, ry, rz, tx, ty, tz);
    return SUCCESS;
}

INT trk_select_axis(void)
{
    static INT cyc = 0;
    /* forced axis */
    if (trk_axis_mode == 1) return TRK_AXIS_X;
    if (trk_axis_mode == 2) return TRK_AXIS_Y;
    if (trk_axis_mode == 3) return TRK_AXIS_Z;
    /* cycle */
    cyc = (cyc % 3) + 1; /* 1,2,3 */
    return cyc;
}

/*
 * trk_core: Minimal tracking execution hook.
 * Call this inside a dedicated tracking startseq or just before imaging
 * if embedding as a subsegment. Publishes a placeholder result.
 */
INT trk_core(void)
{
    /* Placeholder: publish zero motion with current (stub) timestamp. */
    trk_publish(trk_now_ms_stub(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    return SUCCESS;
}

void trk_plan_pass(TRK_PLAN *plan_out)
{
    if (!plan_out) return;
    plan_out->axis = (TRK_AXIS)trk_select_axis();
    plan_out->skip_phase_encode = 1; /* ensure Gy1=0 or equivalent */
    plan_out->nav_echo = 1;          /* single-echo tracking by default */
}
