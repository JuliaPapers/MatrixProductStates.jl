using MAT
using MatrixProductStates
using LinearAlgebra
BLAS.set_num_threads(2)

#Spin model parameters
const na = 60 # number of atoms
const od = 33 # optical depth of cloud
const ad = 2.5 * 60 / na #atomic distance in micro m
const cloud_sig = 23.6344 / ad # cloud length
const cloud_coup = exp.(-((1:na) - (na + 1) / 2) .^ 2 / 2 / cloud_sig^2) # atomic cloud distribution
const gam_1d = cloud_coup / sum(cloud_coup) / 2 * od # coupling of atoms
const gam_eg = 1.0 # eg spontaneous decay rate
const del_p = 0.0 # detuning of pump beam
const k_wg = 0.5 * pi # waveguide wavevector
const rj = collect(1.0:na) #sort!(rand(na)*na) # atom positions
const k_in = k_wg # pump beam wavevector 
const gam_exp = 2 * pi * 6.065e6 # spontaneous emmision rate
const f_amp_exp = sqrt.([0.0589, 0.0721, 0.0995, 0.1637, 0.3081, 0.6395, 1.2121, 1.8898,
    2.6039, 4.2050, 7.1291, 10.4823, 17.0816, 27.1592, 42.8378, 71.7874] / gam_exp / 1e-6)
const f_amp = f_amp_exp[11]

#Rydberg specific parameters
const om = 10.0 / 6.065 / 2.0 # control beam Rabi frequency
const k_c = 0.0 # control wavevector
const del_s = 0.0 # two photon detuning from s level
const gam_sp = 0.100 / 6.065
const gam_pg = 0.100 / 6.065

# rmax = 20 na = 70 
#uu = [524.328+89.9671im, 524.328-89.9671im, 649.737+219.429im, 649.737-219.429im, 488.928]
#lam = [-0.228929 + 0.189648im, -0.228929 - 0.189648im, 0.146279+0.297638im, 0.146279-0.297638im, 0.480032] 

# rmax = 30 na = 60 
#uu = [1055.32, 1156.39 + 264.599im, 1156.39 - 264.599im, 781.661]
#lam = [-0.220397, 0.0354409 + 0.244048im, 0.0354409 - 0.244048im, 0.396262]
#uu = [15158.7, 11895.1 - 1929.93im, 11895.1 + 1929.93im, 2399.43, 16.4076]
#lam = [-0.103573, 0.015448 + 0.126927im, 0.015448 - 0.126927im, 0.30542, 0.606657]
#uu = [90866.8, 59173.0 - 18223.1im, 59173.0 + 18223.1im, 5257.17, 107.47, 1.26558]
#lam = [-0.0606795, 0.0112804 + 0.0784944im, 0.0112804 - 0.0784944im, 0.246432, 0.48336, 0.720283]

# rmax = 20 na = 60 
const uu = [0.704528 + 135.691im, 0.704528 - 135.691im, 225.917]
const lam = [0.226209 + 0.32374im, 0.226209 - 0.32374im, 0.475997]

#uu = [ 2255.07, 686.082 + 91.2384im, 686.082 - 91.2384im, 477.07]
#lam = [-0.0998312, 0.0646318 + 0.25377im, 0.0646318-0.25377im, 0.424938]
#uu = [-508.38 - 1018.61im, -508.38 + 1018.61im, -1546.1 - 1942.74im, -1546.1 + 1942.74im,
#        28.5203]
#lam = [ -0.0374226 + 0.193987im, -0.0374226 - 0.193987im, 0.250214 + 0.0887921im, 
#       0.250214 - 0.0887921im, 0.58104]
#uu = [-658.963 + 91.3732im, -658.963 - 91.3732im, 309.325 + 1085.49im, 309.325 - 1085.49im, 
#       709.204, 4.33617]
#lam = [-0.0921073 + 0.171392im, -0.0921073 - 0.171392im, 0.124872 + 0.194013im, 
#       0.124872 - 0.194013im, 0.382177, 0.670268]

# rmax = 20 na = 50
#uu = [1740.29, 2277.16 + 454.662im, 2277.16 - 454.662im, 945.959, 6.06471]
#lam = [-0.126487, 0.0183872 + 0.140738im, 0.0183872 - 0.140738im, 0.296793, 0.601841]
#uu = [ 57.1125, 170.91 + 211.667im, 170.91 - 211.667im, 336.281]
#lam = [ -0.298989, 0.0548962 + 0.260436im, 0.0548962 - 0.260436im, 0.382366]


# rmax = 20 na = 40
#uu = [19014.9 - 3038.05im, 19014.9 + 3038.05im, 2635.02, 47.4863, 0.531659]
#lam = [-0.0167917 + 0.0377784im, -0.0167917 - 0.0377784im, 0.155726, 0.386972, 0.653397]

# rmax = 20 na = 30
#uu = [-2652.81-1864.93im, -2652.81 + 1864.93im, 274.344, 5.91125, 0.0704647]
#lam = [0.0313486 + 0.0360902im, 0.0313486 - 0.0360902im, 0.179561, 0.407673, 0.666632]

# rmax = 20 na = 20
#uu = [1350.25, 707.234, 15.7581, 0.426333, 0.0053846]
#lam = [-0.0138335, 0.0500349, 0.19712, 0.418572, 0.672633]

# pure dephasing
const gam_gg = 0.0
const gam_ss = 0.0
const gam_ee = 0.0

# simulation parameters
const dt = 0.01
const t_fin = 0.1
const d = 4
const d_max = 160
const measure_int = 5
const path_data = "/home/jdouglas/data/"
const base_filename = string(path_data, "Ryd_Dens_N", na, "_D", d_max,
    "_Tf", t_fin, "_f", round(f_amp; digits=3), "_dt", dt, "_three_exp_float32_gsp",
    round(gam_sp; digits=3), "_gpg", round(gam_pg; digits=3))


# input pulse envelope
function f(t)

    trise = 0.8e-6 * gam_exp
    tup = 2e-6 * gam_exp

    if t < 0
        envelope = 0.0
    elseif t < trise
        envelope = (1.0 + cos(pi * (t - trise) / trise)) / 2
    elseif t <= tup + trise
        envelope = 1.0
    elseif t <= 2 * trise + tup
        envelope = (1.0 + cos(pi * (t - tup - trise) / trise)) / 2
    else
        envelope = 0.0
    end

    f_amp * sqrt(envelope)

end

# local spin operators
const hgg = [1 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0]
const hee = [0 0 0 0; 0 1 0 0; 0 0 0 0; 0 0 0 0]
const hss = [0 0 0 0; 0 0 0 0; 0 0 1 0; 0 0 0 0]
const hpp = [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 1]
const hge = [0 1 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0]
const hes = [0 0 0 0; 0 0 1 0; 0 0 0 0; 0 0 0 0]
const hsp = [0 0 0 0; 0 0 0 0; 0 0 0 1; 0 0 0 0]
const hgp = [0 0 0 1; 0 0 0 0; 0 0 0 0; 0 0 0 0]
const heg = hge'
const hse = hes'
const hps = hsp'
const hpg = hgp'
const id = Matrix{Float64}(I, 4, 4)

# types used in mps representation
const TN = Complex{Float32}
const TA = Array


function time_evolve()

    # construct left-canonical MPS for the initial state
    rho, dims = mpsgroundstate(TN, TA, na, d_max, d^2)

    #Create measurement operators
    IDlmps = makemps(TN, TA, [jj -> id[:]], na, d^2)
    ELmpo = makempo(TN, TA, [jj->id jj->im * sqrt(gam_1d[jj] / 2) * exp(im * k_wg * rj[jj]) * hge
            jj->0 jj->id], na, d)
    ILmpo = applyMPOtoMPO(ELmpo, conj_mpo(ELmpo))
    ILlmps = mpo_to_mps(TN, TA, ILmpo)
    IL2mpo = applyMPOtoMPO(applyMPOtoMPO(ELmpo, ILmpo), conj_mpo(ELmpo))
    IL2lmps = mpo_to_mps(TN, TA, IL2mpo)
    NEmpo = makempo(TN, TA, [jj->id jj->hee; jj->0 jj->id], na, d)
    NElmps = mpo_to_mps(TN, TA, NEmpo)
    NSmpo = makempo(TN, TA, [jj->id jj->hss; jj->0 jj->id], na, d)
    NSlmps = mpo_to_mps(TN, TA, NSmpo)
    NPmpo = makempo(TN, TA, [jj->id jj->hpp; jj->0 jj->id], na, d)
    NPlmps = mpo_to_mps(TN, TA, NPmpo)
    ERmpo = makempo(TN, TA, [jj->id jj->im * sqrt(gam_1d[jj] / 2) * exp(-im * k_wg * rj[jj]) * hge
            jj->0 jj->id], na, d)
    ERmpo[1][1, :, 2, :] = f(0.0) * id + im * sqrt(gam_1d[1] / 2) * exp(-im * k_wg * rj[1]) * hge
    IRmpo = applyMPOtoMPO(ERmpo, conj_mpo(ERmpo))
    IR2mpo = applyMPOtoMPO(applyMPOtoMPO(ERmpo, IRmpo),
        conj_mpo(ERmpo))
    IRlmps = mpo_to_mps(TN, TA, IRmpo)
    IR2lmps = mpo_to_mps(TN, TA, IR2mpo)

    #step times and measurement times
    t = 0.0:dt:t_fin
    t_m = t[1:measure_int:end]
    tstep = length(t) - 1

    # preallocating measurement arrays
    tr_rho = zeros(TN, length(t_m))
    e_pop = zeros(TN, length(t_m))
    s_pop = zeros(TN, length(t_m))
    p_pop = zeros(TN, length(t_m))
    e_pop_j = zeros(TN, na, length(t_m))
    s_pop_j = zeros(TN, na, length(t_m))
    p_pop_j = zeros(TN, na, length(t_m))
    I_r = zeros(TN, length(t_m))
    I2_r = zeros(TN, length(t_m))
    I_l = zeros(TN, length(t_m))
    I2_l = zeros(TN, length(t_m))
    times = zeros(tstep, 4)

    # initial measurements
    e_pop[1] = scal_prod_no_conj(NElmps, rho)
    s_pop[1] = scal_prod_no_conj(NSlmps, rho)
    p_pop[1] = scal_prod_no_conj(NPlmps, rho)
    measure_excitations!(rho, (@view e_pop_j[:, 1]), IDlmps, hee[:])
    measure_excitations!(rho, (@view s_pop_j[:, 1]), IDlmps, hss[:])
    measure_excitations!(rho, (@view p_pop_j[:, 1]), IDlmps, hpp[:])
    tr_rho[1] = scal_prod_no_conj(IDlmps, rho)
    I_r[1] = scal_prod_no_conj(IRlmps, rho)
    I2_r[1] = scal_prod_no_conj(IR2lmps, rho)
    I_l[1] = scal_prod_no_conj(ILlmps, rho)
    I2_l[1] = scal_prod_no_conj(IL2lmps, rho)

    # temporary arrays for time evolution
    rho1 = similar(rho)
    rho2 = similar(rho)
    rho3 = similar(rho)
    rho1 .= copy.(rho)
    rho2 .= copy.(rho)
    rho3 .= copy.(rho)
    mpo_size = 6 + 2 * length(lam)
    env1 = build_env(TN, TA, dims, dims)
    env2 = build_env(TN, TA, dims, dims)
    env3 = build_env(TN, TA, dims, dims)
    envop = build_env(TN, TA, dims, dims, ones(na + 1) * mpo_size)

    # time evolution operators for Runge Kutta algorithm
    L1 = construct_L_Ryd(TN, TA, 1, dt / 2, t[1])
    L2 = construct_L_Ryd(TN, TA, 0, 1, t[1] + dt / 2)
    L3 = construct_L_Ryd(TN, TA, 1, dt / 2, t[2])
    L = [L1, L2, L3]

    println("Initialisation complete")
    println(typeof(L))
    println(typeof(rho))
    println(typeof(env1))
    println(typeof(envop))


    # time evolution
    for i = 1:tstep
        time_in = time()

        # update time-evolution operator
        update_L_Ryd!(L1, 1, dt / 2, t[i])
        update_L_Ryd!(L2, 0, 1, t[i] + dt / 2)
        update_L_Ryd!(L3, 1, dt / 2, t[i+1])
        times[i, 1] = time() - time_in

        # Runge-Kutta 4th order time step
        RK4stp_apply_H_half!(dt, L, rho, rho1, rho2, rho3, env1, env2, env3, envop)
        times[i, 2] = time() - times[i, 1] - time_in

        # measurements (every measure_int time steps)
        if rem(i, measure_int) == 0
            mind = div(i, measure_int) + 1
            # atomic state populations
            e_pop[mind] = scal_prod_no_conj(NElmps, rho)
            s_pop[mind] = scal_prod_no_conj(NSlmps, rho)
            p_pop[mind] = scal_prod_no_conj(NPlmps, rho)
            tr_rho[mind] = scal_prod_no_conj(IDlmps, rho)
            measure_excitations!(rho, (@view e_pop_j[:, mind]), IDlmps, hee[:])
            measure_excitations!(rho, (@view s_pop_j[:, mind]), IDlmps, hss[:])
            measure_excitations!(rho, (@view p_pop_j[:, mind]), IDlmps, hpp[:])
            # output right field update
            ERmpo[1][1, :, 2, :] = f(t[i+1]) * id +
                                   im * sqrt(gam_1d[1] / 2) * exp(-im * k_wg * rj[1]) * hge
            IRupdate = apply_site_MPOtoMPO(ERmpo[1],
                conj_site_mpo(ERmpo[1]))
            IR2update = apply_site_MPOtoMPO(
                apply_site_MPOtoMPO(ERmpo[1], IRupdate),
                conj_site_mpo(ERmpo[1]))
            IRlmps[1] = mpo_to_mps_site(IRupdate)
            IR2lmps[1] = mpo_to_mps_site(IR2update)
            # output field measurement
            I_r[mind] = scal_prod_no_conj(IRlmps, rho)
            I2_r[mind] = scal_prod_no_conj(IR2lmps, rho)
            I_l[mind] = scal_prod_no_conj(ILlmps, rho)
            I2_l[mind] = scal_prod_no_conj(IL2lmps, rho)
            times[i, 3] = time() - times[i, 2] - times[i, 1] - time_in
        end

        # saving temporary file
        if rem(i, measure_int * 20) == 0
            write_data_file(string(base_filename, "_temp.mat"), i, t_m, e_pop,
                e_pop_j, s_pop, p_pop, s_pop_j, p_pop_j, tr_rho,
                I_r, I2_r, I_l, I2_l, rho, times)

        end

        # saving mid pulse data
        if i == 10000
            write_data_file(string(base_filename, "_mid_pulse.mat"), i, t_m, e_pop,
                e_pop_j, s_pop, p_pop, s_pop_j, p_pop_j, tr_rho,
                I_r, I2_r, I_l, I2_l, rho, times)
        end

    end

    # saving to final data to file
    write_data_file(string(base_filename, ".mat"), tstep, t_m, e_pop,
        e_pop_j, s_pop, p_pop, s_pop_j, p_pop_j, tr_rho,
        I_r, I2_r, I_l, I2_l, rho, times)


end

function write_data_file(filename, i, t_m, e_pop, e_pop_j, s_pop, p_pop,
    s_pop_j, p_pop_j, tr_rho, I_r, I2_r, I_l, I2_l,
    rho, times)

    file = matopen(filename, "w")
    write(file, "TN", string(TN))
    write(file, "TA", string(TA))
    write(file, "na", na)
    write(file, "gam_1d", gam_1d)
    write(file, "gam_eg", gam_eg)
    write(file, "del_p", del_p)
    write(file, "k_wg", k_wg)
    write(file, "rj", rj)
    write(file, "k_in", k_in)
    write(file, "f_amp", f_amp)
    write(file, "f", f.(t_m))
    write(file, "om", om)
    write(file, "k_c", k_c)
    write(file, "del_s", del_s)
    write(file, "uu", uu)
    write(file, "lam", lam)
    write(file, "gam_gg", gam_gg)
    write(file, "gam_ss", gam_ss)
    write(file, "gam_ee", gam_ee)
    write(file, "gam_sp", gam_sp)
    write(file, "gam_pg", gam_pg)
    write(file, "dt", dt)
    write(file, "t_fin", t_fin)
    write(file, "d_max", d_max)
    write(file, "measure_int", measure_int)

    write(file, "i_last", i)
    write(file, "t_m", collect(t_m))
    write(file, "e_pop", e_pop)
    write(file, "s_pop", s_pop)
    write(file, "p_pop", p_pop)
    write(file, "e_pop_j", e_pop_j)
    write(file, "s_pop_j", s_pop_j)
    write(file, "p_pop_j", p_pop_j)
    write(file, "tr_rho", tr_rho)
    write(file, "I_r", I_r)
    write(file, "I2_r", I2_r)
    write(file, "I_l", I_l)
    write(file, "I2_l", I2_l)
    write(file, "rho", collect.(rho))
    write(file, "times", sum(times, 1))
    close(file)

end

function construct_L_Ryd(::Type{TN}, ::Type{TA}, con, delt, time) where {TN,TA}

    LMPO = Array{TA{TN,4}, 1}(undef, na)
    drj = diff(rj)
    ph = exp.(im * k_wg * drj)
    cp = sqrt.(delt * gam_1d / 2)
    no_exp = length(lam)
    max_ind = 6 + 2 * no_exp

    LMPO[1] = zeros(TN, 1, d^2, max_ind, d^2)
    LMPO[1][1, :, 1, :] = kron(id, id)
    LMPO[1][1, :, 2, :] = cp[1] * ph[1] * (kron(id, hge) - kron(heg, id))
    LMPO[1][1, :, 3, :] = cp[1] * ph[1] * (kron(hge, id))
    LMPO[1][1, :, 4, :] = cp[1]' * ph[1]' * (kron(id, hge))
    LMPO[1][1, :, 5, :] = cp[1]' * ph[1]' * (kron(hge, id) - kron(id, heg))
    for exp_ind = 1:no_exp
        LMPO[1][1, :, 5+2*exp_ind-1, :] = sqrt(-im * delt * uu[exp_ind] * lam[exp_ind]) *
                                          (kron(hss, id) + kron(hpp, id))
        LMPO[1][1, :, 5+2*exp_ind, :] = sqrt(im * delt * uu[exp_ind] * lam[exp_ind]) *
                                        (kron(id, hss) + kron(id, hpp))
    end
    LMPO[1][1, :, max_ind, :] = local_l(1, con, delt, time)

    LMPO[na] = zeros(TN, max_ind, d^2, 1, d^2)
    LMPO[na][1, :, 1, :] = local_l(na, con, delt, time)
    LMPO[na][2, :, 1, :] = cp[na] * kron(hge, id)
    LMPO[na][3, :, 1, :] = -cp[na] * (kron(heg, id) - kron(id, hge))
    LMPO[na][4, :, 1, :] = -cp[na]' * (kron(id, heg) - kron(hge, id))
    LMPO[na][5, :, 1, :] = cp[na]' * kron(id, hge)
    for exp_ind = 1:no_exp
        LMPO[na][5+2*exp_ind-1, :, 1, :] = sqrt(-im * delt * uu[exp_ind] * lam[exp_ind]) *
                                           (kron(hss, id) + kron(hpp, id))
        LMPO[na][5+2*exp_ind, :, 1, :] = sqrt(im * delt * uu[exp_ind] * lam[exp_ind]) *
                                         (kron(id, hss) + kron(id, hpp))
    end
    LMPO[na][max_ind, :, 1, :] = kron(id, id)

    for jj = 2:(na-1)
        LMPO[jj] = zeros(TN, max_ind, d^2, max_ind, d^2)
        LMPO[jj][1, :, 1, :] = kron(id, id)
        LMPO[jj][1, :, 2, :] = cp[jj] * ph[jj] * (kron(id, hge) - kron(heg, id))
        LMPO[jj][1, :, 3, :] = cp[jj] * ph[jj] * (kron(hge, id))
        LMPO[jj][1, :, 4, :] = cp[jj]' * ph[jj]' * (kron(id, hge))
        LMPO[jj][1, :, 5, :] = cp[jj]' * ph[jj]' * (kron(hge, id) - kron(id, heg))
        LMPO[jj][1, :, max_ind, :] = local_l(jj, con, delt, time)
        LMPO[jj][2, :, max_ind, :] = cp[jj] * kron(hge, id)
        LMPO[jj][3, :, max_ind, :] = -cp[jj] * (kron(heg, id) - kron(id, hge))
        LMPO[jj][4, :, max_ind, :] = -cp[jj]' * (kron(id, heg) - kron(hge, id))
        LMPO[jj][5, :, max_ind, :] = cp[jj]' * kron(id, hge)
        LMPO[jj][max_ind, :, max_ind, :] = kron(id, id)
        LMPO[jj][2, :, 2, :] = ph[jj] * kron(id, id)
        LMPO[jj][3, :, 3, :] = ph[jj] * kron(id, id)
        LMPO[jj][4, :, 4, :] = ph[jj]' * kron(id, id)
        LMPO[jj][5, :, 5, :] = ph[jj]' * kron(id, id)
        for exp_ind = 1:no_exp
            LMPO[jj][1, :, 5+2*exp_ind-1, :] = sqrt(-im * delt * uu[exp_ind] * lam[exp_ind]) *
                                               (kron(hss, id) + kron(hpp, id))
            LMPO[jj][1, :, 5+2*exp_ind, :] = sqrt(im * delt * uu[exp_ind] * lam[exp_ind]) *
                                             (kron(id, hss) + kron(id, hpp))
            LMPO[jj][5+2*exp_ind-1, :, max_ind, :] = sqrt(-im * delt * uu[exp_ind] * lam[exp_ind]) *
                                                     (kron(hss, id) + kron(hpp, id))
            LMPO[jj][5+2*exp_ind, :, max_ind, :] = sqrt(im * delt * uu[exp_ind] * lam[exp_ind]) *
                                                   (kron(id, hss) + kron(id, hpp))
            LMPO[jj][5+2*exp_ind-1, :, 5+2*exp_ind-1, :] = lam[exp_ind] * kron(id, id)
            LMPO[jj][5+2*exp_ind, :, 5+2*exp_ind, :] = lam[exp_ind] * kron(id, id)
        end
    end

    return LMPO

end


function update_L_Ryd!(LMPO, con, delt, time)

    no_exp = length(lam)
    max_ind = 6 + 2 * no_exp
    LMPO[1][1, :, max_ind, :] = local_l(1, con, delt, time)
    LMPO[na][1, :, 1, :] = local_l(na, con, delt, time)
    for jj = 2:na-1
        LMPO[jj][1, :, max_ind, :] = local_l(jj, con, delt, time)
    end

end

function local_l(jj, con, delt, time)

    con / na * kron(id, id) + delt * (
        (im * del_p - (gam_eg + gam_1d[jj] + gam_ee) / 2) * kron(hee, id) -
        (im * del_p + (gam_eg + gam_1d[jj] + gam_ee) / 2) * kron(id, hee) +
        (im * del_s - gam_ss / 2 - gam_sp / 2) * kron(hss, id) -
        (im * del_s + gam_ss / 2 + gam_sp / 2) * kron(id, hss) +
        (-gam_gg / 2) * kron(hgg, id) -
        (+gam_gg / 2) * kron(id, hgg) +
        (-gam_pg / 2) * kron(hpp, id) -
        (+gam_pg / 2) * kron(id, hpp) +
        gam_gg * kron(hgg, hgg) +
        gam_ss * kron(hss, hss) +
        gam_ee * kron(hee, hee) +
        gam_sp * kron(hps, hps) +
        gam_pg * kron(hgp, hgp) +
        (gam_eg + gam_1d[jj]) * kron(hge, hge) +
        im * f(time) * sqrt(gam_1d[jj] / 2) * exp(im * k_in * rj[jj]) * (kron(heg, id) - kron(id, hge)) +
        im * f(time) * sqrt(gam_1d[jj] / 2) * exp(-im * k_in * rj[jj]) * (kron(hge, id) - kron(id, heg)) +
        im * om * exp(im * k_c * rj[jj]) * (kron(hse, id) - kron(id, hes)) +
        im * om * exp(-im * k_c * rj[jj]) * (kron(hes, id) - kron(id, hse)))

end

function measure_excitations!(rho, popj, IDlmps, locmat)

    imat = IDlmps[1][1, :, 1]
    na = length(rho)
    for jj = 1:na
        IDlmps[jj][1, :, 1] = locmat
        popj[jj] = scal_prod_no_conj(IDlmps, rho)
        IDlmps[jj][1, :, 1] = imat
    end
end

time_evolve()