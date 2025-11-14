/*
 * Tracking utilities header (lightweight, PSD-agnostic)
 *
 * Provides a tiny interface for TR-level motion tracking exchange.
 * Can be included from any PSD (.e) to publish/consume tracking results
 * without coupling to waveform specifics.
 */
#ifndef TRACKING_H_
#define TRACKING_H_

/* Fallbacks for EPIC status if not included yet */
#ifndef SUCCESS
#define SUCCESS 0
#endif
#ifndef FAILURE
#define FAILURE (-1)
#endif

/* EPIC type aliases are usually present; fall back to C types if needed */
#ifndef INT
#define INT int
#endif
#ifndef SHORT
#define SHORT short
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Result structure for a single tracking solve (angles in degrees, trans in mm) */
typedef struct {
    INT  ts_ms;      /* optional timestamp in ms; 0 if unknown */
    double rx;       /* rotation about X (deg) */
    double ry;       /* rotation about Y (deg) */
    double rz;       /* rotation about Z (deg) */
    double tx;       /* translation along X (mm) */
    double ty;       /* translation along Y (mm) */
    double tz;       /* translation along Z (mm) */
    INT  valid;      /* 1 if valid/new; 0 if empty */
} TRK_RESULT;

/* Shared latest result (simple single-writer, single-reader model) */
extern volatile TRK_RESULT g_trk_latest;

/* Tunables */
extern INT trk_enabled;     /* master enable (1=on) */
extern INT trk_period_tr;   /* run tracking every K TRs (K>=1) */
extern INT trk_fresh_ms;    /* how long a result is considered fresh (ms); <=0 disables check */

/* Axis selection mode
 * 0 = cycle X->Y->Z per tracking TR
 * 1 = force X, 2 = force Y, 3 = force Z
 */
extern INT trk_axis_mode;

/* API */
void trk_init(void);
void trk_clear(void);
void trk_publish(INT ts_ms, double rx, double ry, double rz, double tx, double ty, double tz);
INT  trk_peek_latest(TRK_RESULT *out);
INT  trk_is_fresh(INT now_ms);
INT  trk_should_run(INT tr_index);

/* External ingress: host/RTP can push a result directly */
INT  trk_receive_external(INT ts_ms, double rx, double ry, double rz, double tx, double ty, double tz);

/* Optional helpers (stubs) */
/* Axis helpers */
typedef enum {
    TRK_AXIS_X = 1,
    TRK_AXIS_Y = 2,
    TRK_AXIS_Z = 3
} TRK_AXIS;

INT  trk_select_axis(void);    /* choose axis according to trk_axis_mode (cycles if 0) */
INT  trk_core(void);           /* minimal tracking execution; publishes a placeholder */

/* Tracking pass plan: describes how to configure a tracking-only TR */
typedef struct {
    TRK_AXIS axis;   /* which axis to use as frequency-encode (1D nav) */
    INT skip_phase_encode; /* 1 to disable PE (Gy1=0 or equivalent) */
    INT nav_echo;     /* 1 or 2, which echo would host the nav (for single-echo use 1) */
} TRK_PLAN;

/* Create a plan for the upcoming tracking TR based on current settings */
void trk_plan_pass(TRK_PLAN *plan_out);

#ifdef __cplusplus
}
#endif

#endif /* TRACKING_H_ */
