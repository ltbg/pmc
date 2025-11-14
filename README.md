# pmc
pmc psd modification

Step 1:
add new RF to grass
  1. 【grass -addRF1.e】add RF and readout，including filter and DAB，when simulation，there‘s pulsegen error （gxwtrk not found）【grad_rf_grass.globals.h and grad_rf_grass.h need to modify too】
  2. 【grass -addRF2.e】delete readout DAB filter, only RF
