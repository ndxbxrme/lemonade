MAX_FILTER_STAGES = 5
SAMPLE_RATE = 48000
LOG_2 = 0.693147181
PI = Math.PI
LOG_10 = 2.302585093
dB2rap = (dB) ->
  Math.exp(db * LOG_10 / 20)
rap2dB = (rap) ->
  20 * Math.log(rap) / LOG_10
filterTypes = ['lowpass', 'highpass', 'lowpass2', 'highpass2', 'bandpass', 'notch', 'peak', 'lowshelf', 'highshelf']
Filter = (Ftype, Ffreq, Fq, Fstages, FsampleRate) ->
  SAMPLE_RATE = SAMPLE_RATE or FsampleRate
  type = filterTypes.indexOf Ftype
  return if type is -1
  stages = Math.min MAX_FILTER_STAGES, Fstages
  freq = Ffreq
  q = Fq
  gain = 1.0
  order = null
  bufferSize = null
  c = new Array(3)
  d = new Array(3)
  oldc = new Array(3)
  oldd = new Array(3)
  xd = new Array(3)
  yd = new Array(3)
  x = new Array(MAX_FILTER_STAGES + 1)
  y = new Array(MAX_FILTER_STAGES + 1)
  oldx = new Array(MAX_FILTER_STAGES + 1)
  oldy = new Array(MAX_FILTER_STAGES + 1)
  needsinterpolation = null
  firsttime = 0
  abovenq = 0
  oldabovenq = 0
  i = 0
  while i < 3
    oldc[i] = 0
    oldd[i] = 0
    c[i] = 0
    d[i] = 0
    i++
  cleanup = ->
    i = 0
    while i < MAX_FILTER_STAGES + 1
      x[i] = c1: 0, c2: 0
      y[i] = c1: 0, c2: 0
      oldx[i] = x[i]
      oldy[i] = y[i]
      i++
    needsinterpolation = 0
  setfreq = (frequency) ->
    frequency=0.1 if (frequency<0.1) 
    rap = freq/frequency
    rap=1.0/rap if (rap<1.0) 
    oldabovenq=abovenq
    abovenq = frequency>(SAMPLE_RATE/2-100.0)
    nyquistthresh=(abovenq^oldabovenq)

    if((rap>3.0) or (nyquistthresh isnt 0)) 
      i = 0
      while i < 3
        oldc[i] = c[i]
        oldd[i] = d[i]
        i++
      while i < MAX_FILTER_STAGES + 1
        oldx[i] = x[i]
        oldy[i] = y[i]
        i++	
      needsinterpolation=1 if (firsttime is 0) 
    freq = frequency
    computefiltercoefs()
    firsttime=0
  setfreq_and_q = (frequency, _q) ->
    q = _q
    setfreq frequency
  setq = (_q) ->
    q = _q
    computefiltercoefs()
  settype = (_type) ->
    type = filterTypes.indexOf _type
    computefiltercoefs()
  setstages = (_stages) ->
    _stages = MAX_FILTER_STAGES - 1 if _stages >= MAX_FILTER_STAGES
    cleanup()
    computefiltercoefs()
  setgain = (dBgain) ->
    gain = dB2rap dBgain
    computefiltercoefs()
  computefiltercoefs = () ->
    tmp = null
    omega = null
    sn = null 
    cs = null
    alpha = null
    beta = null
    zerocoefs=0
    if (freq>(SAMPLE_RATE/2-100.0)) 
        freq=SAMPLE_RATE/2-100.0
        zerocoefs = 1
    freq=0.1 if (freq<0.1) 
    q=0.0 if (q<0.0) 
    tmpq = null
    tmpgain = null
    if (stages is 0) 
      tmpq=q
      tmpgain=gain
    else
      tmpq=(if q>1.0 then Math.pow(q,1.0/(stages+1.0)) else q)
      tmpgain=Math.pow(gain, 1.0/(stages+1))
    

    switch(type) 
      when 0 #  LPF 1 pole
        if (zerocoefs is 0) 
          tmp=Math.exp(-2.0*PI*freq/SAMPLE_RATE)
        else 
          tmp=0.0
        c[0]=1.0-tmp
        c[1]=0.0
        c[2]=0.0
        d[1]=tmp
        d[2]=0.0
        order=1
      when 1 #HPF 1 pole
        if (zerocoefs is 0) 
          tmp=Math.exp(-2.0*PI*freq/SAMPLE_RATE)
        else 
          tmp=0.0
        c[0]=(1.0+tmp)/2.0
        c[1]=-(1.0+tmp)/2.0
        c[2]=0.0
        d[1]=tmp;d[2]=0.0
        order=1
      when 2 #LPF 2 poles 
        if (zerocoefs is 0)
          omega=(2*PI*freq/SAMPLE_RATE)
          sn=Math.sin(omega)
          cs=Math.cos(omega)
          alpha=sn/(2*tmpq)
          tmp=1+alpha
          c[0]=(1.0-cs)/2.0/tmp
          c[1]=(1.0-cs)/tmp
          c[2]=(1.0-cs)/2.0/tmp
          d[1]=-2.0*cs/tmp*(-1.0)
          d[2]=(1.0-alpha)/tmp*(-1.0)
        else
          c[0]=1.0
          c[1]=0.0
          c[2]=0.0
          d[1]=0.0
          d[2]=0.0
        order=2
      when 3 #HPF 2 poles 
        if (zerocoefs is 0)
          omega=(2*PI*freq/SAMPLE_RATE)
          sn=Math.sin(omega)
          cs=Math.cos(omega)
          alpha=sn/(2*tmpq)
          tmp=1+alpha
          c[0]=(1.0+cs)/2.0/tmp
          c[1]=-(1.0+cs)/tmp
          c[2]=(1.0+cs)/2.0/tmp
          d[1]=-2.0*cs/tmp*(-1.0)
          d[2]=(1.0-alpha)/tmp*(-1.0)
        else
          c[0]=0.0
          c[1]=0.0
          c[2]=0.0
          d[1]=0.0
          d[2]=0.0
        order=2
      when 4 #BPF 2 poles 
        if (zerocoefs is 0)
          omega=(2*PI*freq/SAMPLE_RATE)
          sn=Math.sin(omega)
          cs=Math.cos(omega)
          alpha=sn/(2*tmpq)
          tmp=1+alpha
          c[0]=(alpha/tmp*sqrt(tmpq+1))
          c[1]=0
          c[2]=(-alpha/tmp*sqrt(tmpq+1))
          d[1]=-2.0*cs/tmp*(-1.0)
          d[2]=(1.0-alpha)/tmp*(-1.0)
        else
          c[0]=0.0
          c[1]=0.0
          c[2]=0.0
          d[1]=0.0
          d[2]=0.0
        order=2
      when 5 #NOTCH 2 poles 
        if (zerocoefs is 0)	
          omega=(2*PI*freq/SAMPLE_RATE);
          sn=Math.sin(omega);
          cs=Math.cos(omega);
          alpha=(sn/(2.0*sqrt(tmpq)));
          tmp=1.0+alpha;
          c[0]=1.0/tmp;
          c[1]=-2.0*cs/tmp;
          c[2]=1.0/tmp;		
          d[1]=-2.0*cs/tmp*(-1.0);
          d[2]=(1-alpha)/tmp*(-1);
        else
          c[0]=1.0
          c[1]=0.0
          c[2]=0.0
          d[1]=0.0
          d[2]=0.0
        order=2
      when 6 #PEAK (2 poles)
        if (zerocoefs is 0)
          omega=(2*PI*freq/SAMPLE_RATE)
          sn=Math.sin(omega)
          cs=Math.cos(omega)
          tmpq*=3.0
          alpha=sn/(2.0*tmpq)
          tmp=1.0+alpha/tmpgain
          c[0]=(1.0+alpha*tmpgain)/tmp
          c[1]=(-2.0*cs)/tmp
          c[2]=(1.0-alpha*tmpgain)/tmp
          d[1]=-2.0*cs/tmp*(-1.0)
          d[2]=(1-alpha/tmpgain)/tmp*(-1)
        else
          c[0]=1.0
          c[1]=0.0
          c[2]=0.0
          d[1]=0.0
          d[2]=0.0
        order=2
      when 7 #Low Shelf - 2 poles
        if (zerocoefs is 0)
          omega=(2*PI*freq/SAMPLE_RATE)
          sn=Math.sin(omega)
          cs=Math.cos(omega)
          tmpq=sqrt(tmpq)
          alpha=sn/(2*tmpq)
          beta=sqrt(tmpgain)/tmpq
          tmp=(tmpgain+1.0)+(tmpgain-1.0)*cs+beta*sn
          c[0]=tmpgain*((tmpgain+1.0)-(tmpgain-1.0)*cs+beta*sn)/tmp		
          c[1]=2.0*tmpgain*((tmpgain-1.0)-(tmpgain+1.0)*cs)/tmp
          c[2]=tmpgain*((tmpgain+1.0)-(tmpgain-1.0)*cs-beta*sn)/tmp	
          d[1]=-2.0*((tmpgain-1.0)+(tmpgain+1.0)*cs)/tmp*(-1.0)
          d[2]=((tmpgain+1.0)+(tmpgain-1.0)*cs-beta*sn)/tmp*(-1.0)
        else
          c[0]=tmpgain
          c[1]=0.0
          c[2]=0.0
          d[1]=0.0
          d[2]=0.0
        order=2
      when 8 #High Shelf - 2 poles
        if (zerocoefs is 0)
          omega=(2*PI*freq/SAMPLE_RATE)
          sn=Math.sin(omega)
          cs=Math.cos(omega)
          tmpq=sqrt(tmpq)
          alpha=sn/(2*tmpq)
          beta=sqrt(tmpgain)/tmpq
          tmp=(tmpgain+1.0)-(tmpgain-1.0)*cs+beta*sn
          c[0]=tmpgain*((tmpgain+1.0)+(tmpgain-1.0)*cs+beta*sn)/tmp	
          c[1]=-2.0*tmpgain*((tmpgain-1.0)+(tmpgain+1.0)*cs)/tmp
          c[2]=tmpgain*((tmpgain+1.0)+(tmpgain-1.0)*cs-beta*sn)/tmp		
          d[1]=2.0*((tmpgain-1.0)-(tmpgain+1.0)*cs)/tmp*(-1.0)
          d[2]=((tmpgain+1.0)-(tmpgain-1.0)*cs-beta*sn)/tmp*(-1.0)
        else
          c[0]=1.0
          c[1]=0.0
          c[2]=0.0
          d[1]=0.0
          d[2]=0.0
        order=2
      else #wrong type
       type=0
       computefiltercoefs()
  singlefilterout = (smp, x, y, c, d) ->
    i = null
    y0 = null
    if order is 1
      i = 0
      while i < bufferSize
        y0=smp[i]*c[0]+x.c1*c[1]+y.c1*d[1]
        y.c1=y0
        x.c1=smp[i]
        smp[i]=y0
        i++
    if order is 2
      i = 0
      while i < bufferSize
        y0=smp[i]*c[0]+x.c1*c[1]+x.c2*c[2]+y.c1*d[1]+y.c2*d[2]
        y.c2=y.c1
        y.c1=y0
        x.c2=x.c1
        x.c1=smp[i]
        smp[i]=y0
      i++
  filterout = (smp, bufferSize_) ->
    ismp = null
    bufferSize = bufferSize_
    i = null
    if (needsinterpolation isnt 0)
      ismp=new Array(bufferSize)
      i = 0
      while i < bufferSize
        ismp[i]=smp[i]
        i++
      i = 0
      while i < stages + 1
        singlefilterout(ismp,oldx[i],oldy[i],oldc,oldd)
        i++
    i = 0
    while i < stages + 1
      singlefilterout(smp,x[i],y[i],c,d)
      i++

    if (needsinterpolation isnt 0)
      i = 0
      while i < bufferSize
        x= i / bufferSize
        smp[i]=ismp[i]*(1.0-x)+smp[i]*x
    ismp = null
    needsinterpolation=0
  #late init
  cleanup()
  setfreq_and_q Ffreq, Fq
  firsttime = 1
  d[0] = 0
  setfreq: setfreq
  setq: setq
  setstages: setstages
  setgain: setgain
  filterout: filterout
module.exports = Filter