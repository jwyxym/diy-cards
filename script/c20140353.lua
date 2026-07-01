local s,id,o=GetID()

function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id,LOCATION_MZONE)
    c:EnableReviveLimit()
    aux.AddSynchroMixProcedure(c,s.matfilter,nil,nil,aux.NonTuner(nil),1,99)

    -- ② 对方不能对应统王通常陷阱发动怪兽效果
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.chainop)
    c:RegisterEffect(e1)

    -- ③ 玩家标记：此卡在场上时统王陷阱才可追加抽卡
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(id)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1,0)
    c:RegisterEffect(e2)

    -- ③ ADJUST：重载统王陷阱追加抽1
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(0xff)
    e3:SetOperation(s.adjop)
    c:RegisterEffect(e3)
end

function s.matfilter(c,syncard)
    return c:IsSetCard(0x1c6) and c:IsType(TYPE_MONSTER)
end

-- ②
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():GetType()==TYPE_TRAP and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
        and ep==tp then
        Duel.SetChainLimit(s.chainlm)
    end
end

function s.chainlm(e,rp,tp)
    return rp==tp or not e:IsActiveType(TYPE_MONSTER)
end

-- ③
function s.trapfilter(c)
    return c:IsSetCard(0x1c6) and c:GetType()==TYPE_TRAP
end

function s.adjop(e,tp,eg,ep,ev,re,r,rp)
    if not s.globle_check then
        s.globle_check=true
        local traps=Duel.GetMatchingGroup(s.trapfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        local dominus_draw={}
        for tc in aux.Next(traps) do
            local qlist={}
            local boolean=true
            while boolean do
                boolean=tc:IsOriginalEffectProperty(function(ef)
                    if ef:IsHasType(EFFECT_TYPE_ACTIVATE) and not s.in_array(ef,qlist) then
                        qlist[#qlist+1]=ef return true
                    end
                    return false
                end)
            end
            for _,ef in ipairs(qlist) do
                local qe=ef:Clone()
                local orig=ef:GetOperation()
                qe:SetOperation(function(e2,tp2,eg2,ep2,ev2,r2,rp2)
                    if orig then orig(e2,tp2,eg2,ep2,ev2,r2,rp2) end
                    if Duel.IsPlayerAffectedByEffect(tp2,id) and Duel.IsPlayerCanDraw(tp2,1) and Duel.GetFlagEffect(tp2,id)==0 and Duel.SelectYesNo(tp2,aux.Stringid(id,0)) then
                        Duel.RegisterFlagEffect(tp2,id,RESET_PHASE+PHASE_END,0,1)
                        Duel.Draw(tp2,1,REASON_EFFECT)
                    end
                end)
                tc:RegisterEffect(qe)
                dominus_draw[#dominus_draw+1]=ef
            end
        end
        for _,ef in ipairs(dominus_draw) do
            ef:Reset()
        end
    end
    e:Reset()
end

function s.in_array(b,list)
    if not list then return false end
    for _,ct in pairs(list) do
        if ct==b then return true end
    end
    return false
end
