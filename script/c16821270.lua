--救世游戏-狂徒
local s,id,o=GetID()
function s.initial_effect(c)
	--特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--送去墓地    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function s.costfilter(c)
	return c:IsSetCard(0xdf99) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c):GetFirst()
	Duel.ConfirmCards(1-tp,sc)
	Duel.ShuffleHand(tp)
    sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local sc=e:GetLabelObject()
    if c:IsRelateToEffect(e) and sc:IsRelateToEffect(e) then
    	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    	sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    	local sg=Group.FromCards(c,sc)
        sg:KeepAlive()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_END)
		e1:SetCountLimit(1)
    	e1:SetLabelObject(sg)
		e1:SetOperation(s.regop)
		Duel.RegisterEffect(e1,tp)    	
    end
	--不能双召翻转        
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.sumlimit)
    if Duel.GetTurnPlayer()==tp then
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e3,tp)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e4,tp)
	--适配    
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(id)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	if Duel.GetTurnPlayer()==tp then
		e5:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e5:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	Duel.RegisterEffect(e5,tp)
    s[0]={}
	s[1]={}
	local race=1
	while race<RACE_ALL do
		s[0][race]=Group.CreateGroup()  
		s[0][race]:KeepAlive()  
		s[1][race]=Group.CreateGroup()  
		s[1][race]:KeepAlive()
		race=race<<1
	end
	--刷新场地信息    
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetCode(EVENT_ADJUST)
	e6:SetOperation(s.adjustop)
    if Duel.GetTurnPlayer()==tp then
		e6:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e6:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	Duel.RegisterEffect(e6,tp)
end
function s.sumfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc) and c:IsStatus(STATUS_EFFECT_ENABLED)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	if sumtype==SUMMON_TYPE_DUAL then return false end
	if sumpos and bit.band(sumpos,POS_FACEDOWN)>0 then return false end
	local tp=sump
	return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_MZONE,0,1,nil,c:GetRace())
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerAffectedByEffect(tp,id) then return end
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
    local sg=Group.CreateGroup()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local race=1
	while race<RACE_ALL do
		local rg=g:Filter(Card.IsRace,nil,race)
		local rc=rg:GetCount()
		if rc>1 then
        	rg:Sub(s[tp][race]:Filter(Card.IsRace,nil,race))
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local dg=rg:Select(tp,rc-1,rc-1,nil)
			sg:Merge(dg)
		end
		race=race<<1
	end
	if sg:GetCount()>0 then
		Duel.SendtoGrave(sg,REASON_RULE)
		Duel.Readjust()
	end
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local race=1
	while race<RACE_ALL do
		s[tp][race]:Clear()
		s[tp][race]:Merge(g:Filter(Card.IsRace,nil,race))
		race=race<<1
	end
end
function s.cfilter(c)
	return c:GetFlagEffect(id)>0
end    
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local sg=e:GetLabelObject():Filter(s.cfilter,nil)
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
    	and sg:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)>1 
        and sg:GetCount()>1 then
        Duel.Hint(HINT_CARD,0,id)
        for tc in aux.Next(sg) do
    		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then    		
        		local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(id,2))
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_CHAIN_SOLVING)
				e1:SetRange(LOCATION_MZONE)
				e1:SetCondition(s.bhcon)
				e1:SetOperation(s.bhop)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
                tc:ResetFlagEffect(id)
    		end
        end 
        Duel.SpecialSummonComplete()   
    end    
    sg:DeleteGroup()
    e:Reset()
end
function s.bhcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()==e:GetHandler() and e:GetHandler():IsAbleToHand()
end
function s.bhop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=c:GetControler())
end    
function s.tgfilter(c)
	return c:IsSetCard(0xdf99) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end