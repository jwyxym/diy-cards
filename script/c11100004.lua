--铁机龙战·绝零外壳
local m=11100004
local cm=_G["c"..m]
function c11100004.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,m)
	e2:SetCondition(cm.spcon)
	e2:SetTarget(cm.sptg)
	e2:SetOperation(cm.spop)
	c:RegisterEffect(e2) 
local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,m+1000)
	e3:SetCondition(cm.con)
	e3:SetTarget(cm.thtg)
	e3:SetOperation(cm.thop)
	c:RegisterEffect(e3)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(cm.filter3,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function cm.filter3(c,tp,tc)
local seq=tc:GetSequence()
	local a
	local b
	if seq>0 then a=seq-1 end
	if seq<4 then b=seq+1 end
	return c:IsSetCard(0xa60) and (c:GetSequence()==a or c:GetSequence()==b)
end
function cm.filter4(c,tp,tc)
local seq=tc:GetSequence()
	local a
	local b
	if seq>0 then a=seq-1 end
	if seq<4 then b=seq+1 end
	return c:IsType(TYPE_LINK) and (c:GetSequence()==a or c:GetSequence()==b)
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function cm.filter(c)
	return c:IsSetCard(0xa60) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsControler(tp) or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
		local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_DECK,0,nil)   
		 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
		local nseq=math.log(bit.rshift(s,16),2)
	 	Duel.MoveSequence(c,nseq)
		if g:GetCount()>0 then 
			Duel.BreakEffect() 
			local tc=g:Select(tp,1,1,nil):GetFirst() 
			Duel.SSet(tp,tc) 
			if Duel.IsExistingMatchingCard(cm.filter4,tp,LOCATION_MZONE,0,1,nil,tp,c) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
	  end  
	end   
end   
function cm.cfilter(c)
	return c:IsSetCard(0xa60) 
end
function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		
		local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cm.splimit2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	end
end
function cm.splimit2(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xa60)
end











