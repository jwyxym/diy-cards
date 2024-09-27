--苍炎祈祷者
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(this.spcon1)
	e2:SetTarget(this.sptg1)
	e2:SetOperation(this.spop1)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id+1)
	e1:SetTarget(this.target)
	e1:SetOperation(this.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,id+2)
    e2:SetCondition(this.actcon)
	e2:SetTarget(this.lvtg)
	e2:SetOperation(this.lvop)
	c:RegisterEffect(e2)
end
function this.cfilter(c,tp)
	return c:IsSetCard(0x678) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
function this.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(this.cfilter,1,nil,tp)
end
function this.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function this.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function this.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21300410,0,TYPES_TOKEN_MONSTER,1000,1000,2,RACE_WYRM,ATTRIBUTE_FIRE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function this.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21300410,0,TYPES_TOKEN_MONSTER,1000,1000,2,RACE_WYRM,ATTRIBUTE_FIRE) then
		local token=Duel.CreateToken(tp,21300410)
		if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,nil) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
            if tc then Duel.Destroy(tc,REASON_EFFECT) end
        end
	end
end
function this.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
function this.actcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
    and c:IsReason(REASON_EFFECT)
end
function this.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and this.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(this.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,this.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function this.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local sel=0
		local lvl=1
		if tc:IsLevel(1) then
			sel=Duel.SelectOption(tp,aux.Stringid(93850690,2))
		else
			sel=Duel.SelectOption(tp,aux.Stringid(93850690,2),aux.Stringid(93850690,3))
		end
		if sel==1 then
			lvl=-1
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
