--孤独摇滚 喜多郁代
local cm,m=GetID()

function cm.initial_effect(c)
    Duel.EnableGlobalFlag(GLOBALFLAG_SPSUMMON_COUNT)
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
	function cm.AddLinkProcedure2(c,f,min,max,gf,string)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(string)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_EXTRA)
		if max==nil then max=c:GetLink() end
		e1:SetCondition(cm.LinkCondition(f,min,max,gf))
		e1:SetTarget(cm.LinkTarget(f,min,max,gf))
		e1:SetOperation(Auxiliary.LinkOperation(f,min,max,gf))
		e1:SetValue(SUMMON_TYPE_LINK)
		c:RegisterEffect(e1)
		return e1
	end
	--link summon
	cm.AddLinkProcedure(c,nil,2,2,cm.lcheck,aux.Stringid(m,7))
	cm.AddLinkProcedure2(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2,cm.lcheck2,aux.Stringid(m,8))
	c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --atkup
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(400)
	c:RegisterEffect(e2)
    --tohand
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(cm.thcon)
    e3:SetCost(aux.bfgcost)
	e3:SetTarget(cm.thtg)
	e3:SetOperation(cm.thop)
	c:RegisterEffect(e3)
    --spsummon
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(cm.sptg)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
    if not cm.global_check then
        cm.global_check=true
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_ADJUST)
        e1:SetCondition(cm.adcone)
        e1:SetOperation(cm.adope)
        Duel.RegisterEffect(e1,0)
        local e2=e1:Clone()
        e2:SetCode(EVENT_SPSUMMON_SUCCESS)
        e2:SetCondition(cm.adconsp)
        e2:SetOperation(cm.adopsp)
        Duel.RegisterEffect(e2,0)
    end
end

function cm.lfcheck(c)
	return not c:IsLink(2)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLink,1,nil,2)
end

function cm.lcheck2(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_SPIRIT)
end

function cm.LConditionFilter(c,f,lc,e)
	return (c:IsFaceup() or not c:IsOnField() or e:IsHasProperty(EFFECT_FLAG_SET_AVAILABLE))
		and c:IsCanBeLinkMaterial(lc) and (c:IsLocation(0x04) or c:IsLinkType(TYPE_SPIRIT)) and (not f or f(c))
end

function cm.GetLinkMaterials(tp,f,lc,e)
	local mg=Duel.GetMatchingGroup(cm.LConditionFilter,tp,0x06,0,nil,f,lc,e)
	local mg2=Duel.GetMatchingGroup(Auxiliary.LExtraFilter,tp,LOCATION_HAND+LOCATION_SZONE,LOCATION_ONFIELD,nil,f,lc,tp)
	if mg2:GetCount()>0 then mg:Merge(mg2) end
	return mg
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
			mg=og:Filter(cm.LConditionFilter,nil,f,c,e)
		else
			mg=cm.GetLinkMaterials(tp,f,c,e)
		end
		if lmat~=nil then
			if not cm.LConditionFilter(lmat,f,c,e) then return false end
			mg:AddCard(lmat)
		end
		local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
		if fg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) then return false end
		Duel.SetSelectedCard(fg)
		return mg:CheckSubGroup(Auxiliary.LCheckGoal,minc,maxc,tp,c,gf,lmat)
	end
end

function cm.LinkTarget(f,minc,maxc,gf)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,lmat,min,max)
		local minc=minc
		local maxc=maxc
		if min then
			if min>minc then minc=min end
			if max<maxc then maxc=max end
			if minc>maxc then return false end
		end
		local mg=nil
		if og then
			mg=og:Filter(cm.LConditionFilter,nil,f,c,e)
		else
			mg=cm.GetLinkMaterials(tp,f,c,e)
		end
		if lmat~=nil then
			if not cm.LConditionFilter(lmat,f,c,e) then return false end
			mg:AddCard(lmat)
		end
		local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
		Duel.SetSelectedCard(fg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
		local cancel=Duel.IsSummonCancelable()
		local sg=mg:SelectSubGroup(tp,Auxiliary.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
		if sg then
			sg:KeepAlive()
			e:SetLabelObject(sg)
			return true
		else return false end
	end
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

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsLink,tp,0x04,0x04,1,nil,8)
end

function cm.thtfilter(c)
    return c:IsAbleToHand() and c:IsType(TYPE_PENDULUM)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thtfilter,tp,0x01,0,1,nil) and Duel.IsExistingMatchingCard(cm.thtfilter,tp,0,0x01,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0x01)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,0x01)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local a1=Duel.IsExistingMatchingCard(cm.thtfilter,tp,0x01,0,1,nil)
    local a2=Duel.IsExistingMatchingCard(cm.thtfilter,tp,0,0x01,1,nil)
    if (not a1) and (not a2) then return false end
    local g1=Group.CreateGroup()
    local g2=Group.CreateGroup()
    if a1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        g1=Duel.SelectMatchingCard(tp,cm.thtfilter,tp,0x01,0,1,1,nil)
    end
    if a2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        g2=Duel.SelectMatchingCard(1-tp,cm.thtfilter,1-tp,0x01,0,1,1,nil)
    end
    if g1 then
        Duel.DisableShuffleCheck()
        Duel.SendtoHand(g1,tp,REASON_EFFECT)
    end
    if g2 then
        Duel.DisableShuffleCheck()
        Duel.SendtoHand(g2,1-tp,REASON_EFFECT)
    end
    if g1 then Duel.ConfirmCards(1-tp,g1) end
    if g2 then Duel.ConfirmCards(tp,g2) end
    Duel.ShuffleHand(tp)
    Duel.ShuffleHand(1-tp)
    Duel.ShuffleDeck(tp)
    Duel.ShuffleDeck(1-tp)
end

function cm.spfilter(c,e,tp)
	return c:IsLink(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(m)
end

function cm.fselect(g,tc,tp)
	return g:GetClassCount(Card.GetLinkCode)==#g and Duel.IsExistingMatchingCard(cm.lkfilter,tp,LOCATION_EXTRA,0,1,nil,g,tc,tp)
end

function cm.lkfilter(c,g,tc,tp)
    local og=g:__add(tc)
	return c:IsLinkSummonable(g,tc,#og,#og) and c:IsLink(og:GetSum(Card.GetLink)) and Duel.GetLocationCountFromEx(tp,tp,og,c)>0
end

function cm.sfilter(c,e,tp)
	return c:IsCode(10700054) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end

function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return false end
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if ft<2 then return false end
        if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
        local g=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
        return g:CheckSubGroup(cm.fselect,2,math.min(ft,3),e:GetHandler(),tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,0x50)
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    Duel.RegisterFlagEffect(tp,110800063,RESET_PHASE+PHASE_END,0,1)
    Duel.RegisterFlagEffect(tp,110810063,RESET_PHASE+PHASE_END,0,1)
    if not (c:IsRelateToChain() and c:IsLocation(LOCATION_MZONE)) then return false end
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<2 then return false end
    if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
    local g=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
    if g:CheckSubGroup(cm.fselect,2,math.min(ft,3),c,tp) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:SelectSubGroup(tp,cm.fselect,false,2,math.min(ft,3),c,tp)
        if not sg then return false end
        local tc=sg:GetFirst()
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
            tc=sg:GetNext()
        end
        Duel.SpecialSummonComplete()
        Duel.AdjustAll()
        local og=Duel.GetOperatedGroup()
        if og:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<sg:GetCount() then return false end
        local tg=Duel.GetMatchingGroup(cm.lkfilter,tp,LOCATION_EXTRA,0,nil,og,c,tp)
        if og:GetCount()==sg:GetCount() and tg:GetCount()>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local rg=tg:Select(tp,1,1,nil)
            Duel.LinkSummon(tp,rg:GetFirst(),og,c,#og+1,#og+1)
            Duel.RegisterFlagEffect(tp,110820063,RESET_PHASE+PHASE_END,0,1)
        end
    end
    Duel.ResetFlagEffect(tp,110800063)
end

function cm.adcone(e)
    local tp=e:GetHandler():GetControler()
    return Duel.GetFlagEffect(tp,110810063)~=0
end

function cm.adope(e)
    local c=e:GetHandler()
    local tp=c:GetControler()
    if Duel.GetFlagEffect(tp,110800063)==0 and Duel.GetFlagEffect(tp,110820063)==0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetValue(1)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function cm.adconsp(e)
    local tp=e:GetHandler():GetControler()
    return Duel.GetFlagEffect(tp,110810063)~=0
end

function cm.adopsp(e)
    local c=e:GetHandler()
    local tp=c:GetControler()
    if Duel.GetFlagEffect(tp,110820063)==1 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetValue(1)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end