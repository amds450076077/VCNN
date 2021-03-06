--
--  Copyright (c) 2014, Facebook, Inc.
--  All rights reserved.
--
--  This source code is licensed under the BSD-style license found in the
--  LICENSE file in the root directory of this source tree. An additional grant
--  of patent rights can be found in the PATENTS file in the same directory.
--
-----------------------
--  modified by Jerry
require 'paths'
local M = { }

function M.parse(arg)
    local cmd = torch.CmdLine()
    cmd:text()
    cmd:text('Torch-7 Training script')
    cmd:text()
    cmd:text('Options:')
    ------------ General options --------------------

    cmd:option('-cache',      'checkpoint/', 'subdirectory in which to save/log experiments')
    cmd:option('-data',       'data/MSCOCO', 'dataset folder')
    cmd:option('-manualSeed',  2,       'Manually set RNG seed')
    cmd:option('-GPU',         1,       'Default preferred GPU')
    cmd:option('-nGPU',        1,       'Number of GPUs to use by default')
    cmd:option('-backend',     'cudnn', 'Options: cudnn | nn')
    ------------- Data options ------------------------
    cmd:option('-nDonkeys',    2,       'number of donkeys to initialize (data loading threads)')
    cmd:option('-imageSize',   256,     'Smallest side of the resized image')
    cmd:option('-imageCrop',   224,     'Height and Width of image crop to be used as input layer')
    cmd:option('-nClasses',    1000,    'number of classes in the dataset')
    ------------- Training options --------------------
    cmd:option('-nEpochs',     55,      'Number of total epochs to run')
    cmd:option('-epochSize',   10000,   'Number of iterations per epoch')
    cmd:option('-epochNumber', 1,       'Manual epoch number (useful on restarts)')
    cmd:option('-batchSize',   128,     'mini-batch size (1 = pure stochastic)')
    cmd:option('-iterSize',    1,       'Number of batches per iteration')
    ---------- Optimization options ----------------------
    cmd:option('-LR',          0.0,     'learning rate; if set, overrides default LR/WD recipe')
    cmd:option('-momentum',    0.9,     'momentum')
    cmd:option('-weightDecay', 5e-4,    'weight decay')
    ---------- Model options ----------------------------------
    cmd:option('-netType',     'milvc',  'Options: milvc_cudnn | milvc_stackvcnn | (stack)vcnn | (stack)vae')
    cmd:option('-dataset',     'mscoco', 'Options: mscoco | mscoco_decouple')
    cmd:option('-retrain',     'none',   'provide path to model to retrain with')
    ---------- Run Options ----------------------------------
    cmd:option('-train',       false,    'run train procedure, note that not every -dataset support trainDataLoader')
    cmd:option('-eval',        false,    'run eval procedure, note that not every -dataset support evalDataLoader')
    cmd:option('-test',        false,    'run test procedure, note that not every -dataset support testDataLoader')
    -- NOTE: Currently -doTrain, -doEval, -doTest options do not passed to donkey.lua
    --       this will be improved in the future
    cmd:text()

    ------------ Options from sepcified network -------------
    local netType = ''
    local backend = 'cudnn'
    for i=1, #arg do
        if arg[i] == '-netType' then
            netType = arg[i+1]
        elseif arg[i] == '-backend' then
            backend = arg[i+1]
        end
    end
    if netType ~= '' then
        cmd:text('Network "' .. netType .. '" options:')
        local config = netType
        local net = paths.dofile('models/' .. config .. '.lua')
        net.arguments(cmd)
        cmd:text()
    end

    local opt = cmd:parse(arg or {})
    if (not opt.train) and (not opt.eval) and (not opt.test) then
        cmd:error('Must specify at least one running scheme: train, eval or test.')
    end
    -- append dataset to cache name
    opt.cache = path.join(opt.cache, opt.dataset)
    -- add commandline specified options
    opt.save = paths.concat(opt.cache,
                            cmd:string(opt.netType, opt,
                                       {retrain=true, optimState=true, cache=true, data=true}))
    -- add date/time
    opt.save = paths.concat(opt.save, ',' .. os.date():gsub(' ',''))
    return opt
end

return M
