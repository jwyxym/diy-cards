-- 黑鲨子机 (ID: 61000081)
local s,id,o=GetID()

function s.initial_effect(c)
	-- 超量召唤手续：1星怪兽×2
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()

	-- ①：以场上1只怪兽为对象，这张卡当作装备卡给那只怪兽装备（双方回合均可发动，HOPT）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)

	-- ②-1：有这张卡装备的怪兽攻击力变成0
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetValue(0)
	c:RegisterEffect(e2)

	-- ②-2：有这张卡装备的怪兽效果无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果逻辑 ====================

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=c end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or c:IsControler(1-tp) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

	-- 目标怪兽存活且表侧表示时执行装备
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if not Duel.Equip(tp,c,tc) then return end

		-- 装备对象限制绑定
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end