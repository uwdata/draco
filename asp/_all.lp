% Collection of ASP files that can be used to quickly run an experiment.
% E.g. clingo asp/_all.lp test.lp

% #include "asp/define.lp".
% #include "asp/generate.lp".
% #include "asp/hard.lp".
% #include "asp/soft.lp".
% #include "asp/weights.lp".
% #include "asp/assign_weights.lp".
% #include "asp/optimize.lp".
% #include "asp/output.lp".
% % #include "asp/topk-lua.lp".

#include "define.lp".
#include "generate.lp".
#include "hard.lp".
#include "soft.lp".
#include "weights.lp".
#include "assign_weights.lp".
#include "optimize_draco.lp".
#include "output.lp".
#include "compare.lp".
#include "assign_compare_weights.lp".
#include "compare_weights.lp".
