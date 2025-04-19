--深池的惊诧
function c31280319.initial_effect(c)
	--额外特召
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCountLimit(1,31280319)
	e1:SetCondition(c31280319.condition)
	e1:SetTarget(c31280319.target)
	e1:SetOperation(c31280319.activate)
	c:RegisterEffect(e1)
	--场上墓地回手
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,31280319)
	e2:SetCondition(c31280319.condition2)
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(c31280319.target2)
	e2:SetOperation(c31280319.operation2)
	c:RegisterEffect(e2)
    if not c31280319.global_check then
		c31280319.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c31280319.checkop)
		Duel.RegisterEffect(ge1,0)
    end   
end    
function c31280319.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local atk=0
	while tc do
		if tc:IsRace(RACE_DRAGON) and tc:IsType(TYPE_RITUAL) then
			if tc:GetSummonPlayer()==tp then
				Duel.RegisterFlagEffect(tc:GetSummonPlayer(),31280319,RESET_PHASE+PHASE_END,0,1)
			end
			tc:RegisterFlagEffect(31280319,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
function c31280319.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,31280319)~=0
end


function c31280319.spfilter(c,e,tp)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c31280319.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280319.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and e:GetHandler():IsCanOverlay() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c31280319.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c31280319.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToEffect(e) then
		c:CancelToGrave()
    	Duel.Overlay(g:GetFirst(),Group.FromCards(c))
        local tc=g:GetFirst()
        tc:RegisterFlagEffect(31280319,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c31280319.condition1)
		e1:SetOperation(c31280319.operation1)
		Duel.RegisterEffect(e1,tp)
	end
end
function c31280319.condition1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(31280319)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function c31280319.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function c31280319.condition2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsRace(RACE_DRAGON) and rc:IsControler(tp) and rc:IsType(TYPE_RITUAL)
end
function c31280319.relfilter(c,tp)
	return c:IsSetCard(0xca3) or c:IsControler(1-tp)
end
function c31280319.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c31280319.relfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c31280319.relfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,c31280319.relfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c31280319.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end