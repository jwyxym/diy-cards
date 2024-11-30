--金焰之魂
function c19000018.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(19000018,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_RACE)
	e0:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	e0:SetValue(RACE_WYRM)
	c:RegisterEffect(e0)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000018,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+19000018)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,1050186)
	e1:SetCondition(c19000018.spcon)
	e1:SetTarget(c19000018.sptg)
	e1:SetOperation(c19000018.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(19000018,2))
	e2:SetCountLimit(1,19000018+100)
	e2:SetRange(LOCATION_PZONE)
	c:RegisterEffect(e2)
	--change level
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19000018,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,19000018+200)
	e3:SetTarget(c19000018.lvltg)
	e3:SetOperation(c19000018.lvlop)
	c:RegisterEffect(e3)
	if not c19000018.global_check then
		c19000018.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c19000018.regcon)
		ge1:SetOperation(c19000018.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c19000018.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp) and not c:IsCode(19000018)
end
function c19000018.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c19000018.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c19000018.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
function c19000018.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(eg,EVENT_CUSTOM+19000018,re,r,rp,ep,e:GetLabel())
end
function c19000018.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
function c19000018.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c19000018.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19000018.filter(c)
	return c:IsFaceup() and not c:IsLevel(12) and c:IsLevelAbove(1) and not c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function c19000018.lvltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19000018.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19000018.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c19000018.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c19000018.lvlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(12)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_DRAGON)
		tc:RegisterEffect(e2)
	end
end