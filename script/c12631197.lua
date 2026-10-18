-- 无余烬的灰灭
local s,id,o=GetID()
local SET_HAIMETSU=0x1ad
local CARD_VIDOS=78783557

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.fuscon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.fstg)
    e2:SetOperation(s.fsop)
    c:RegisterEffect(e2)
end
s.fusion_effect=true
s.listed_series={SET_HAIMETSU}

--==================== ① ====================
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if not re or rp==tp then return false end
    return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)>0
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
    if Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,0,1,1,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    if not c then return false end
    if c:IsLocation(LOCATION_EXTRA) then
        return not c:IsRace(RACE_PYRO)
    end
    return false
end

function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    return re and rp~=tp
end

function s.filter0(c)
    return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

function s.filter1(c,e)
    return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end

function s.filter2(c,e,tp,m,f,chkf)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_PYRO) and (not f or f(c))
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end

function s.fcheck(tp,sg,fc)
    return sg:IsExists(Card.IsCode,1,nil,CARD_VIDOS)
end

function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local chkf=tp
        local mg=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        aux.FCheckAdditional=s.fcheck
        local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
        if not res then
            local ce=Duel.GetChainMaterial(tp)
            if ce~=nil then
                local fgroup=ce:GetTarget()
                local mg3=fgroup(ce,e,tp)
                local mf=ce:GetValue()
                res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
            end
        end
        aux.FCheckAdditional=nil
        return res
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,3200)
end

function s.fsop(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp
    local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
    aux.FCheckAdditional=s.fcheck
    local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
    local mg3=nil
    local sg2=nil
    local ce=Duel.GetChainMaterial(tp)
    if ce~=nil then
        local fgroup=ce:GetTarget()
        mg3=fgroup(ce,e,tp)
        local mf=ce:GetValue()
        sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
    end
    if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
        local sg=sg1:Clone()
        if sg2 then sg:Merge(sg2) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg:Select(tp,1,1,nil)
        local tc=tg:GetFirst()
        if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
            local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
            tc:SetMaterial(mat)
            if mat:IsExists(Card.IsFacedown,1,nil) then
                local cg=mat:Filter(Card.IsFacedown,nil)
                Duel.ConfirmCards(1-tp,cg)
            end
            Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        else
            local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
            local fop=ce:GetOperation()
            fop(ce,e,tp,tc,mat2)
        end
        tc:CompleteProcedure()
        Duel.BreakEffect()
        Duel.Recover(tp,3200,REASON_EFFECT)
    end
    aux.FCheckAdditional=nil
end