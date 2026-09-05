--风来剑（装备魔法卡）
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,45205409)
	
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	
	--equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	
	--攻击力上升
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	
	--淑女装备时：免疫魔陷
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetCondition(s.eqcon)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	
	--淑女装备时：装备怪兽不会被效果破坏
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetCondition(s.eqcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	
	--淑女装备时：这张卡自身不会被效果破坏
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCondition(s.selfcon)
	e8:SetValue(1)
	c:RegisterEffect(e8)
	
	--淑女装备时：直接攻击
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	e6:SetCondition(s.eqcon)
	c:RegisterEffect(e6)
	
	--②效果：检索淑女记述的魔陷
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCountLimit(1,id)
	e7:SetCondition(s.thcon)
	e7:SetTarget(s.thtg)
	e7:SetOperation(s.thop)
	c:RegisterEffect(e7)
end

function s.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end

function s.atkval(e,c)
	if c:IsCode(45205409) then return 800 end
	return 500
end

function s.eqcon(e)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	return tc and tc:IsCode(45205409)
end

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and (te:IsActiveType(TYPE_SPELL) or te:IsActiveType(TYPE_TRAP))
end

function s.selfcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:IsCode(45205409)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	return tc and tc:IsCode(45205409)
end

function s.thfilter(c)
	return aux.IsCodeListed(c,45205409) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

return s
