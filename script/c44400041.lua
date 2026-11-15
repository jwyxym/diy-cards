-- 狄娜托·提塔司图
local s,id,o=GetID()
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段
local SET_YE_CU=0x97f          -- 「业簇」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」

function s.initial_effect(c)
	-- 融合召唤手续：「狄娜托·图娜」＋「水晶花」怪兽３只
	c:EnableReviveLimit()
	aux.AddCodeList(c,CARD_DINATO_TUNA)
	aux.AddFusionProcMix(c,true,true,CARD_DINATO_TUNA,s.matfilter,s.matfilter,s.matfilter)

	-- ①：这张卡在场上·墓地存在，卡名也当做「狄娜托·图娜」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(CARD_DINATO_TUNA)
	c:RegisterEffect(e1)

	-- ②：对方在主要阶段把效果发动时才能发动。那张卡返回卡组·额外卡组。那之后，选自己手卡·场上１张装备卡送去墓地或者选墓地１张装备卡给这张卡装备。装备的场合，直到这个主要阶段结束前，自己不能把这个效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon2)
	e2:SetTarget(s.distg2)
	e2:SetOperation(s.disop2)
	c:RegisterEffect(e2)

	-- ③：双方的主要阶段把场上的这张卡返回额外卡组才能发动。从卡组·墓地·除外状态把１只「狄娜托·图娜」特殊召唤，从手卡·墓地·除外状态把「业簇」卡尽可能地给这个效果特殊召唤的怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon3)
	e3:SetCost(s.spcost3)
	e3:SetTarget(s.sptg3)
	e3:SetOperation(s.spop3)
	c:RegisterEffect(e3)
end

-- 融合素材过滤（「水晶花」怪兽）
function s.matfilter(c,fc,sub,mg,sg)
	return c:IsSetCard(SET_CRYSTAL_FLOWER)
end

--------------------------------------------------------------------------------
-- ②效果：对方主要阶段响应弹回卡组，送墓/装备二选一与阶段自肃
--------------------------------------------------------------------------------
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	return rp==1-tp and (phase==PHASE_MAIN1 or phase==PHASE_MAIN2)
		and Duel.GetFlagEffect(tp,id)==0
end

function s.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
end

function s.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end

function s.eqfilter2(c,tc,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(tc)
end

function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		local b1=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
		local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsRelateToEffect(e) and c:IsFaceup()
			and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_GRAVE,0,1,nil,c,tp)
		if not (b1 or b2) then return end
		local op=0
		if b1 and b2 then
			op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		elseif b1 then
			op=Duel.SelectOption(tp,aux.Stringid(id,0))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
		end
		Duel.BreakEffect()
		if op==0 then
			-- 分支1：选自己手卡·场上１张装备卡送去墓地
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
			if #g>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		else
			-- 分支2：选墓地１张装备卡给这张卡装备
			if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter2),tp,LOCATION_GRAVE,0,1,1,nil,c,tp)
			local tc=g:GetFirst()
			if tc and Duel.Equip(tp,tc,c) then
				-- 装备的场合，直到这个主要阶段结束前，自己不能把这个效果发动
				local phase=Duel.GetCurrentPhase()
				local reset_phase=(phase==PHASE_MAIN1) and PHASE_MAIN1 or PHASE_MAIN2
				Duel.RegisterFlagEffect(tp,id,RESET_PHASE+reset_phase,0,1)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- ③效果：主要阶段回额外，特召「狄娜托·图娜」并装备「业簇」
--------------------------------------------------------------------------------
function s.spcon3(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	return phase==PHASE_MAIN1 or phase==PHASE_MAIN2
end

function s.spcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.spfilter3(c,e,tp)
	return c:IsCode(CARD_DINATO_TUNA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp,c)>0
			and Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.ye_cu_filter(c,tc,tp)
	return c:IsSetCard(SET_YE_CU) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(tc)
end

function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter3),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 从手卡·墓地·除外状态把「业簇」卡尽可能地装备
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft<=0 or sc:IsFacedown() then return end
		local eqg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.ye_cu_filter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,sc,tp)
		if #eqg>0 then
			Duel.BreakEffect()
			local max_equip=math.min(ft,#eqg)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local sg=eqg:Select(tp,1,max_equip,nil)
			for tc in aux.Next(sg) do
				Duel.Equip(tp,tc,sc,true,true)
			end
			Duel.EquipComplete()
		end
	end
end