local s,id,o=GetID()
function s.initial_effect(c)

	aux.AddFusionProcFun2(c,s.tmfilter,s.fifilter)
	c:EnableReviveLimit()

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atkfilter)
	e1:SetValue(200)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.tfcon)
	e3:SetTarget(s.tftg)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)
end
function s.tmfilter(c)
	return c:IsFusionSetCard(0x74c)
end
function s.fifilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFusionAttribute(ATTRIBUTE_FIRE)
end
function s.atkfilter(e,c)
	return c:IsFaceup() and c:IsSetCard(0x74c)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_FUSION) then return false end
	local d=Duel.GetAttackTarget()
	if d==c then d=Duel.GetAttacker() end
	e:SetLabelObject(d)
	return d~=nil and d:IsFaceup()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local d=e:GetLabelObject()
	if d and d:IsRelateToBattle() then
		Duel.Destroy(d,REASON_EFFECT)
	end
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.tffilter(c)
	return c:IsSetCard(0x74c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tffilter),tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tffilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end