-- 水晶花的戾灾
local s,id,o=GetID()
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段
local SET_YE_CU=0x97f          -- 「业簇」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」

function s.initial_effect(c)
	aux.AddCodeList(c,CARD_DINATO_TUNA)

	-- ①：以自己场上的１只「狄娜托·图娜」怪兽为对象才能发动。那张卡装备的卡尽可能地送去墓地，选那个数量的对方场上的卡送去墓地。对方场上的卡的数量比那个数量少的场合，作为代替，自己可以以下效果适用。●把对方的额外卡组确认，选择最多有那个差值的卡除外。那之后，对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ②：对方把效果发动时把墓地这张卡除外才能发动。选自己墓地１张「业簇」装备魔法卡给自己场上的「狄娜托·图娜」装备。自己场上存在有装备卡装备的「狄娜托·图娜」的场合，作为代替也可以把那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition2)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- ①效果：送墓装备卡，等量送墓对方场上卡（不足时代替：确认额外除外差值＋全场破坏）
--------------------------------------------------------------------------------
function s.tgfilter1(c)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA)
		and c:GetEquipGroup():IsExists(Card.IsAbleToGrave,1,nil)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter1,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_SZONE)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local eqg=tc:GetEquipGroup():Filter(Card.IsAbleToGrave,nil)
	if #eqg==0 then return end
	local ct=Duel.SendtoGrave(eqg,REASON_EFFECT)
	if ct<=0 then return end

	local op_cards=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local op_tg_cards=op_cards:Filter(Card.IsAbleToGrave,nil)

	-- 对方场上的卡的数量比那个数量少
	if #op_cards<ct then
		local diff=ct-#op_cards
		local exg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
		if #exg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 替代分支：确认额外卡组除外差值，破坏场上全部卡
			Duel.ConfirmCards(tp,exg)
			local ex_rm=exg:Filter(Card.IsAbleToRemove,nil,POS_FACEUP)
			if #ex_rm>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local sg=ex_rm:Select(tp,1,math.min(diff,#ex_rm),nil)
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
			local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
			if #dg>0 then
				Duel.BreakEffect()
				Duel.Destroy(dg,REASON_EFFECT)
			end
			return
		end
	end

	-- 基础分支：选那个数量的对方场上的卡送去墓地
	if #op_tg_cards>0 then
		local send_ct=math.min(ct,#op_tg_cards)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=op_tg_cards:Select(tp,send_ct,send_ct,nil)
		if #sg>0 then
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end

--------------------------------------------------------------------------------
-- ②效果：对方发效墓地除外二选一（装备「业簇」或代替无效该效果）
--------------------------------------------------------------------------------
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end

function s.dina_filter(c)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA)
end

function s.dina_filter_for_ec(c,ec)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA) and ec:CheckEquipTarget(c)
end

function s.eqfilter2(c,tp)
	return c:IsSetCard(SET_YE_CU) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp)
		and Duel.IsExistingMatchingCard(s.dina_filter_for_ec,tp,LOCATION_MZONE,0,1,nil,c)
end

function s.dina_with_equip_filter(c)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA) and c:GetEquipCount()>0
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_GRAVE,0,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(s.dina_with_equip_filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsChainDisablable(ev)
	if chk==0 then return b1 or b2 end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)

	if op==0 then
		e:SetCategory(CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	end
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 分支1：选墓地１张「业簇」装备魔法卡给「狄娜托·图娜」装备
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter2),tp,LOCATION_GRAVE,0,1,1,nil,tp)
		local ec=g:GetFirst()
		if not ec then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tg=Duel.SelectMatchingCard(tp,s.dina_filter_for_ec,tp,LOCATION_MZONE,0,1,1,nil,ec)
		local tc=tg:GetFirst()
		if tc then
			Duel.Equip(tp,ec,tc)
		end
	else
		-- 分支2：把那个效果无效
		Duel.NegateEffect(ev)
	end
end