-- 狄娜托12世螺旋踢击！
local s,id,o=GetID()
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段
local SET_YE_CU=0x97f          -- 「业簇」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」

function s.initial_effect(c)
	aux.AddCodeList(c,CARD_DINATO_TUNA)

	-- 规则效果：在规则上也当做「水晶花」「业簇」卡使用
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0a:SetCode(EFFECT_ADD_SETCODE)
	e0a:SetValue(SET_CRYSTAL_FLOWER)
	c:RegisterEffect(e0a)
	local e0b=e0a:Clone()
	e0b:SetValue(SET_YE_CU)
	c:RegisterEffect(e0b)

	-- ①：自己场上存在有装备卡装备的「狄娜托·图娜」，对方把魔法·陷阱卡·怪兽的效果发动时才能发动。那个无效，那张卡返回持有者卡组。这个效果无效的是怪兽效果的场合，可以再选双方场上·墓地１张卡当做装备卡给自己场上「狄娜托·图娜」装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ②：把墓地这张卡除外才能发动。选自己墓地１张「业簇」装备魔法卡给自己场上的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- ①效果：反击无效弹回卡组，怪兽效果时可选双方场上·墓地卡装备
--------------------------------------------------------------------------------
function s.dina_with_equip_filter(c)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA) and c:GetEquipCount()>0
end

function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(s.dina_with_equip_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end

function s.dina_filter(c)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA)
end

function s.eqfilter_any(c,tp)
	return (c:IsLocation(LOCATION_GRAVE) or (c:IsFaceup() and c:IsOnField())) and c:CheckUniqueOnField(tp)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not Duel.NegateActivation(ev) then return end
	if rc:IsRelateToEffect(re) then
		Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end

	-- 这个效果无效的是怪兽效果的场合，可以再选双方场上·墓地１张卡当做装备卡给自己场上「狄娜托·图娜」装备
	if re:IsActiveType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.dina_filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.eqfilter_any,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tg=Duel.SelectMatchingCard(tp,s.dina_filter,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=tg:GetFirst()
		if not tc then return end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local eqg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter_any),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,tc,tp)
		local eq_card=eqg:GetFirst()
		if eq_card then
			Duel.BreakEffect()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(s.eqlimit)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			eq_card:RegisterEffect(e1)
			Duel.Equip(tp,eq_card,tc)
		end
	end
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

--------------------------------------------------------------------------------
-- ②效果：墓地除外选墓地「业簇」装备魔法卡装备
--------------------------------------------------------------------------------
function s.target_mon_filter(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end

function s.eqfilter2(c,tp)
	return c:IsSetCard(SET_YE_CU) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp)
		and Duel.IsExistingMatchingCard(s.target_mon_filter,tp,LOCATION_MZONE,0,1,nil,c)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter2),tp,LOCATION_GRAVE,0,1,1,nil,tp)
	local ec=g:GetFirst()
	if not ec then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tg=Duel.SelectMatchingCard(tp,s.target_mon_filter,tp,LOCATION_MZONE,0,1,1,nil,ec)
	local tc=tg:GetFirst()
	if tc then
		Duel.Equip(tp,ec,tc)
	end
end