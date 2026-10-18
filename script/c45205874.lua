--投鼠忌器
local s,id=GetID()
function s.initial_effect(c)
	--① 以自己场上的1只怪兽和对方场上的1只怪兽为对象才能发动。
	--   自己场上的怪兽作为拥有以下效果的装备卡给对方场上的那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

-- target：自己场上1只怪兽 + 对方场上1只怪兽
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
	end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
end

-- operation
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=2 then return end
	local c1=g:GetFirst()
	local c2=g:GetNext()
	local tc1,tc2
	if c1:IsControler(tp) then tc1=c1; tc2=c2 else tc1=c2; tc2=c1 end
	if not tc1 or not tc2 then return end
	-- 自己怪兽作为装备卡给对方怪兽装备
	if Duel.Equip(tp,tc1,tc2) then
		-- 装备限制
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc2)
		tc1:RegisterEffect(e1)
		-- ●获得装备怪兽的控制权
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e2)
		-- ●对方只能攻击装备了这张卡的怪兽
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_ONLY_BE_ATTACKED)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e3)
		-- ●对方不能把装备怪兽以外的双方的场上·墓地·除外状态的怪兽作为效果的对象
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e4:SetRange(LOCATION_SZONE)
		e4:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
		e4:SetCondition(s.effcon)
		e4:SetTarget(s.efftg)
		e4:SetValue(aux.tgoval)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e4)
	end
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

-- 条件：装备卡和装备对象控制者相同
function s.effcon(e)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	return tc and c:GetControler()==tc:GetControler()
end

-- 过滤：装备怪兽以外的怪兽
function s.efftg(e,c)
	return c~=e:GetHandler():GetEquipTarget() and c:IsType(TYPE_MONSTER)
end

return s
