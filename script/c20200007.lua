--疯狂国度的白女巫
function c20200007.initial_effect(c)
	c:SetSPSummonOnce(20200007)
	--change code
	aux.EnableChangeCode(c,20200003,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_MZONE)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c20200007.spcon)
	c:RegisterEffect(e1)
	--direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	--level change
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20200007,0))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c20200007.lvtg)
	e3:SetOperation(c20200007.lvop)
	c:RegisterEffect(e3)
end
function c20200007.spfilter(c)
	return c:IsSetCard(0xb31) and c:IsFaceup()
end
function c20200007.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c20200007.spfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
function c20200007.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(3) and c:IsSetCard(0xb31)
end
function c20200007.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c20200007.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20200007.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c20200007.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c20200007.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) then
		local op=0
		if tc:IsLevel(3) then op=3
		else op=aux.SelectFromOptions(tp,
			{true,aux.Stringid(20200007,1),3},
			{true,aux.Stringid(20200007,2),-3})
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(op)
		tc:RegisterEffect(e1)
	end
end
