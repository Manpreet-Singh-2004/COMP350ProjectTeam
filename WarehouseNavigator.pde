
PFont mono, titleFont, nameFont;

// ── Palette ──────────────────────────────────────────────────
final color BG         = color(13,17,23);
final color MAP_BG     = color(17,22,29);
final color PANEL_C    = color(20,27,36);
final color BORDER_C   = color(38,52,68);
final color TXT_DIM    = color(80,102,122);
final color TXT_MED    = color(148,172,195);
final color TXT_BRT    = color(205,222,240);
final color GRN        = color(75,215,115);
final color CYAN_C     = color(55,205,205);
final color PURP       = color(155,90,215);
final color YLW        = color(235,185,50);
final color RED_C      = color(210,60,60);
final color ORG        = color(220,110,40);
final color BLUE_B     = color(60,140,225);
final color SHELF_C    = color(38,52,68);
final color PLAYER_COL = color(60,140,225);
final color AI_COL     = color(210,60,60);

final color[] ZONE_BDR  = {color(65,130,215),color(205,155,38),color(55,175,75),color(188,50,50)};
final color[] ZONE_BG   = {color(14,26,50),  color(32,26,8),  color(10,30,12), color(32,10,10)};
final color[] ZONE_DOT  = {color(55,125,215),color(210,160,38),color(50,180,70),color(205,55,55)};
final String[] ZONE_NAME = {"DAIRY","BAKERY","PRODUCE","FROZEN"};

// ── Window / Layout ──────────────────────────────────────────
final int WIN_W = 730, WIN_H = 580;
final int MAP_W = 562;
final int MAP_H = 440;
final int SB_W  = 154;
final int HUD_H = 26;

final int ST_TERMINAL = 7;
int searchedPkgIndex = -1; // -1 means no active search
String[] terminalList;     // Holds our sorted list of packages

// centered layout
int MAP_X, MAP_Y;
int SB_X, SB_Y;

// ── Grid ─────────────────────────────────────────────────────
final int COLS = 22, ROWS = 17;
final float CELL_W = (MAP_W - 4) / float(COLS);
final float CELL_H = (MAP_H - HUD_H - 4) / float(ROWS);

final int[][] ZONE_RECT = {
  {0, 0, 5, 6},
  {17,0, 5, 6},
  {0, 11,5, 6},
  {17,11,5, 6}
};

// ── Player ───────────────────────────────────────────────────
float   px, py;
int     pgx=10, pgy=8;
float   tpx, tpy;
boolean pMoving = false;
float   PSPEED  = 5.5;
float   stamina = 100, maxStam = 100;
boolean sprinting;
int     pCarrying = -1;

// ── AI ───────────────────────────────────────────────────────
float   ax, ay;
int     agx=11, agy=8;
float   tax, tay;
boolean aMoving = false;
float   ASPEED  = 3.8;
int     aCarrying = -1;
int     aiTimer = 0;
boolean showPath = false;
ArrayList<int[]> aiCurrentPath = new ArrayList<int[]>();

// ── Packages ─────────────────────────────────────────────────
final int N_PKG = 6;
int[]     pkgGX      = new int[N_PKG];
int[]     pkgGY      = new int[N_PKG];
int[]     pkgZone    = new int[N_PKG];
String[]  pkgLabel   = new String[N_PKG];
boolean[] pkgDead    = new boolean[N_PKG];
boolean[] pkgSpoiled = new boolean[N_PKG];
boolean[] pkgPickedUp= new boolean[N_PKG];
float[]   pkgTimer   = new float[N_PKG];
float[]   pkgMaxTimer= new float[N_PKG];

int[][] SPAWN = {
  {8,3},{10,3},{12,3},{13,3},
  {8,8},{10,8},{12,8},{13,8},
  {8,13},{10,13},{12,13},{13,13}
};

// ── Score / HUD ──────────────────────────────────────────────
int   score = 0, aiScore = 0, lives = 3, deliveries = 0, aiDeliveries = 0;
int   combo = 0;
float shiftSecs = 120, timeLeft;
int[] zoneDeliveries = new int[4];
int[] aiZoneDeliveries = new int[4];
boolean shiftResolved = false;
String shiftEndReason = "";

// ── 3 Shifts ─────────────────────────────────────────────────
final int TOTAL_SHIFTS = 3;
int   currentShift = 1;
int[] shiftPlayerScore = new int[TOTAL_SHIFTS];
int[] shiftPlayerDel   = new int[TOTAL_SHIFTS];
int[] shiftAiScore     = new int[TOTAL_SHIFTS];
int[] shiftAiDel       = new int[TOTAL_SHIFTS];
int[] shiftOutcome     = new int[TOTAL_SHIFTS]; // 1 player win, 0 tie, -1 rival win
float[] SHIFT_AI_SCALE = {0.75, 1.0, 1.28};

// ── States ───────────────────────────────────────────────────
final int ST_DIFF     = 0;
final int ST_NAME     = 1;
final int ST_PLAY     = 2;
final int ST_PAUSE    = 3;
final int ST_LOST     = 4;
final int ST_SHIFTWIN = 5;
final int ST_RESULTS  = 6;
int gameState = ST_NAME;

// ── Difficulty ───────────────────────────────────────────────
int difficulty = 0;
String[] DIFF_NAMES  = {"EASY","MEDIUM","HARD"};
color[]  DIFF_COLS   = {GRN, YLW, RED_C};
String[] DIFF_DESCS  = {
  "Slow AI · Long timers · More lives",
  "Balanced AI · Normal timers · 3 lives",
  "Fast AI · Short timers · 2 lives"
};
float[] DIFF_AI_SPEED   = {2.0, 3.8, 5.2};
float[] DIFF_PKG_MIN    = {28,  20,  13};
float[] DIFF_PKG_MAX    = {42,  32,  22};
float[] DIFF_SHIFT_SECS = {160, 120, 90};
int[]   DIFF_LIVES      = {4,   3,   2};
int[]   DIFF_AI_INTERVAL= {24,  13,  7};

// ── Player name ──────────────────────────────────────────────
String playerName   = "";
String nameInputBuf = "";

// ── Effects ──────────────────────────────────────────────────
ArrayList<Toast>      toasts = new ArrayList<Toast>();
ArrayList<SpoilAlert> alerts = new ArrayList<SpoilAlert>();
float flashAlpha = 0;
color flashCol = RED_C;
float pulse = 0;
String lossReason = "";

// ── Input ─────────────────────────────────────────────────────
boolean[] KD = new boolean[600];

// ============================================================
void initWarehouseNavigator() {
  mono      = createFont("Courier New", 13, true);
  titleFont = createFont("Arial Bold", 24, true);
  nameFont  = createFont("Arial Bold", 16, true);
  textFont(mono);
  int totalW = MAP_W + SB_W + 10; // 10 = gap between map and sidebar

MAP_X = (width - totalW) / 2;
MAP_Y = (height - MAP_H) / 2 - 55;

SB_X = MAP_X + MAP_W + 10;
SB_Y = MAP_Y;

  nameInputBuf = "";
  playerName = "";
  gameState = ST_NAME;
  difficulty = 0;
  currentShift = 1;
  toasts.clear();
  alerts.clear();
  flashAlpha = 0;
}

// ============================================================
void drawWarehouseNavigator() {
  background(BG);
  pulse += 0.05;

  if (gameState==ST_DIFF) {
    drawDiffScreen();
    return;
  }
  if (gameState==ST_NAME) {
    drawNameScreen();
    return;
  }
  if (gameState==ST_RESULTS) {
    drawResultsScreen();
    return;
  }
  if (gameState==ST_SHIFTWIN) {
    drawMapBG();
    drawSidebar();
    drawShiftSummaryModal();
    return;
  }

  if (gameState==ST_PLAY) updateGame();

  drawMapBG();
  drawPackages();
  drawAIChar();
  drawPlayerChar();
  drawFloatToasts();
  drawHUDBar();
  drawFlash();
  drawSidebar();

  if (gameState==ST_PAUSE) drawPauseOverlay();
  if (gameState == ST_TERMINAL) drawTerminalScreen();
}
