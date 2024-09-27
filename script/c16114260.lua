--龙霸主仙精 Marinyan
Duel.LoadScript("c16199990.lua")
local m,cm=rk.set(16114260,nil,1)
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(cm.spcon)
	c:RegisterEffect(e1)
	--copy effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,m+1)
	e2:SetCost(cm.cost)
	e2:SetTarget(cm.copytg)
	e2:SetOperation(cm.copyop)
	c:RegisterEffect(e2)
end
function cm.spfilter(c,tp)
	return c:IsFaceup() and rk.check(c,"RYUUHA")
end
function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function cm.copyfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and not c:IsType(TYPE_TOKEN) and (c:IsFaceup() or (c:IsLocation(LOCATION_GRAVE) and not c:IsForbidden() and c:CheckUniqueOnField(tp)))
end
function cm.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and cm.copyfilter(chkc,tp) and chkc~=c and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	if chk==0 then return Duel.IsExistingTarget(cm.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c,tp)
end
function cm.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (tc:IsFaceup() or tc:IsLocation(LOCATION_GRAVE)) then
		if not Duel.Equip(tp,tc,c) then return end
		Duel.BreakEffect()
		--equip limit
		local atk=tc:GetBaseAttack()
		local def=tc:GetBaseDefense()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(c)
		e1:SetValue(cm.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		--atk
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_SINGLE)
		ge1:SetCode(EFFECT_UPDATE_ATTACK)
		ge1:SetValue(atk)
		ge1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(ge1)
		local ge2=ge1:Clone()
		ge2:SetCode(EFFECT_UPDATE_DEFENSE)
		ge2:SetValue(def)
		c:RegisterEffect(ge2)
		local code=tc:GetOriginalCodeRule()
		if not tc:IsType(TYPE_TRAPMONSTER) then
			cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD)
		end
	end
end
function cm.eqlimit(e,c)
	return c==e:GetLabelObject()
end