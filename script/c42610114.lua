--小女王 摩卡莫莉
local cm,m=GetID()

function cm.initial_effect(c)
    function cm.AddLinkProcedure(c,f,min,max,gf,string)
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(string)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_SPSUMMON_PROC)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e1:SetRange(LOCATION_EXTRA)
        if max==nil then max=c:GetLink() end
        e1:SetCondition(Auxiliary.LinkCondition(f,min,max,gf))
        e1:SetTarget(Auxiliary.LinkTarget(f,min,max,gf))
        e1:SetOperation(Auxiliary.LinkOperation(f,min,max,gf))
        e1:SetValue(SUMMON_TYPE_LINK)
        c:RegisterEffect(e1)
        return e1
    end
	cm.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLink,2),4,8,aux.Stringid(m,0))
	local e00=Effect.CreateEffect(c)
	e00:SetDescription(aux.Stringid(m,1))
	e00:SetType(EFFECT_TYPE_FIELD)
	e00:SetCode(EFFECT_SPSUMMON_PROC)
	e00:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e00:SetRange(LOCATION_EXTRA)
	e00:SetCondition(cm.LinkCondition(nil,2,8,cm.lcheck))
	e00:SetTarget(cm.LinkTarget(nil,2,8,cm.lcheck))
	e00:SetOperation(Auxiliary.LinkOperation(nil,2,8,cm.lcheck))
	e00:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e00)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,m+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(cm.regcon)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
    --todeck
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(cm.retg)
	e1:SetOperation(cm.reop)
	c:RegisterEffect(e1)
end

function cm.LinkCondition(f,minc,maxc,gf)
	return	function(e,c,og,lmat,min,max)
        if c==nil then return true end
        if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
        local minc=minc
        local maxc=maxc
        if min then
            if min>minc then minc=min end
            if max<maxc then maxc=max end
            if minc>maxc then return false end
        end
        local tp=c:GetControler()
        local mg=nil
        if og then
            mg=og:Filter(Auxiliary.LConditionFilter,nil,f,c,e)
        else
            mg=Auxiliary.GetLinkMaterials(tp,f,c,e)
        end
        if lmat~=nil then
            if not Auxiliary.LConditionFilter(lmat,f,c,e) then return false end
            mg:AddCard(lmat)
        end
        local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
        if fg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) or fg:IsExists(Card.IsLocation,1,nil,0x7b) then return false end
        Duel.SetSelectedCard(fg)
        local ag=Duel.GetFieldGroup(tp,0x04,0)
        local cg=mg:__band(ag)
        if not Group.Equal(cg,ag) then return false end
        return ag:CheckSubGroup(Auxiliary.LCheckGoal,#ag,#ag,tp,c,gf,lmat)
    end
end

function cm.LinkTarget(f,minc,maxc,gf)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,lmat,min,max)
        local ag=Duel.GetFieldGroup(tp,0x04,0)
        if ag then
            ag:KeepAlive()
            e:SetLabelObject(ag)
            return true
        else return false end
    end
end

function cm.lcheck(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_SPELLCASTER)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.spfilter(c,e,tp)
	return ((c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_LINK)) or c:IsLink(2)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(m) and c:IsCanBeEffectTarget(e)
end

function cm.fselect(g,tc,tp)
	return g:GetClassCount(Card.GetLinkCode)==#g and Duel.IsExistingMatchingCard(cm.lkfilter,tp,LOCATION_EXTRA,0,1,nil,g,tc,tp)
end

function cm.lkfilter(c,g,tc,tp)
	local og=g:__add(tc)
	return c:IsLinkSummonable(g,tc,#og,#og) and Duel.GetLocationCountFromEx(tp,tp,oc,c)>0
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(0x10) and chkc:IsControler(tp) and Duel.IsExistingMatchingCard(cm.lkfilter,tp,0x40,0,1,nil,Group.FromCards(chkc),c,tp) end
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local mg=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
    if chk==0 then
        if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return false end
        if ft<=0 then return false end
        if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
        return mg:CheckSubGroup(cm.fselect,1,math.min(ft,#mg),c,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fg=mg:SelectSubGroup(tp,cm.fselect,false,1,math.min(ft,#mg),c,tp)
    Duel.SetTargetCard(fg)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,fg,#fg,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if c:IsRelateToChain() and c:IsLocation(0x04) and #tg>0 then
        if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return false end
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if ft<=0 then return false end
        if #tg>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
        if #tg>ft then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            tg=tg:Select(tp,ft,ft,nil)
        end
        local tc=tg:GetFirst()
        while tc do
            Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            tc:RegisterEffect(e2)
            tc=tg:GetNext()
        end
        Duel.SpecialSummonComplete()
        local og=Duel.GetOperatedGroup()
        Duel.AdjustAll()
        if og:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<tg:GetCount() then return end
        local lg=Duel.GetMatchingGroup(cm.lkfilter,tp,LOCATION_EXTRA,0,nil,og,c,tp)
        if og:GetCount()==tg:GetCount() and lg:GetCount()>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local rg=lg:Select(tp,1,1,nil)
            Duel.LinkSummon(tp,rg:GetFirst(),og,c,#og+1,#og+1)
        end
    end
end

function cm.tgrfilter(c)
    return (c:IsRace(RACE_SPELLCASTER) or c:IsLink(2)) and c:IsAbleToDeck()
end

function cm.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.tgrfilter,tp,0x10,0,1,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,0x10)
end

function cm.reop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,cm.tgrfilter,tp,0x10,0,1,5,nil)
    if #g>0 then
        Duel.HintSelection(g)
        Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
    end
end