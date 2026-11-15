-- 水晶花·黑水晶 (ID: 44400034)
local s,id,o=GetID()
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段
local SET_YE_CU=0x97f          -- 「业簇」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」

function s.initial_effect(c)
	-- 记录关联卡名
	aux.AddCodeList(c,CARD_DINATO_TUNA)

	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。选卡组１张「业簇」装备魔法卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	-- 离场前状态记录：在移动前检测是否持有装备卡
	local e_p=Effect.CreateEffect(c)
	e_p:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e_p:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e_p:SetCode(EVENT_LEAVE_FIELD_P)
	e_p:SetOperation(s.prev_equip_check)
	c:RegisterEffect(e_p)

	-- ②-A（主动起动入口）：自己主要阶段，把场上有装备卡的这张卡解放才能发动。特召卡组「狄娜托·图娜」
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2a:SetType(EFFECT_TYPE_IGNITION)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,id+o*100)
	e2a:SetCost(s.spcost2a)
	e2a:SetTarget(s.sptg2a)
	e2a:SetOperation(s.spop2)
	c:RegisterEffect(e2a)

	-- ②-B（被动诱发入口）：有装备卡装备的这张卡被其他卡解放的场合也能诱发特召
	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(id,1))
	e2b:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2b:SetProperty(EFFECT_FLAG_DELAY)
	e2b:SetCode(EVENT_RELEASE)
	e2b:SetCountLimit(1,id+o*100)
	e2b:SetCondition(s.spcon2b)
	e2b:SetTarget(s.sptg2b)
	e2b:SetOperation(s.spop2)
	c:RegisterEffect(e2b)

	-- ③：对方回合才能发动。把墓地这张卡除外，选择以下１个效果适用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o*200)
	e3:SetCondition(s.quickcon3)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.target3)
	e3:SetOperation(s.operation3)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- ①效果：召唤·特召成功卡组装备「业簇」
--------------------------------------------------------------------------------
function s.eqfilter(c,tc,tp)
	return c:IsSetCard(SET_YE_CU) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(tc)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,c,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,c,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.Equip(tp,tc,c)
	end
end

--------------------------------------------------------------------------------
-- ②效果：主动起动 ＋ 被动诱发 双模处理
--------------------------------------------------------------------------------
function s.spfilter2(c,e,tp)
	return c:IsCode(CARD_DINATO_TUNA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ②-A 主动起动：场上主动解放自身
function s.spcost2a(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipCount()>0 and c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end

function s.sptg2a(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- ②-B 被动诱发：被其他效果解放进入墓地
function s.prev_equip_check(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetEquipCount()>0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end

function s.prev_eq_filter(c,mc)
	return c:GetPreviousEquipTarget()==mc
end

function s.spcon2b(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetFlagEffect(id)>0 or Duel.IsExistingMatchingCard(s.prev_eq_filter,tp,0xff,0xff,1,nil,c))
end

function s.sptg2b(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- 统一结算：从卡组特殊召唤「狄娜托·图娜」
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------------------------------------------------------
-- ③效果：对方回合二选一（回收抽卡 / 融合召唤）
--------------------------------------------------------------------------------
function s.quickcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end

function s.tdfilter_mon(c)
	return c:IsCode(CARD_DINATO_TUNA) and (c:IsFaceup() or not c:IsOnField()) and c:IsAbleToDeck()
end

function s.tdfilter_eq(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToDeck()
end

function s.b1_check(tp,e)
	return Duel.IsExistingMatchingCard(s.tdfilter_mon,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,e:GetHandler())
		and Duel.IsPlayerCanDraw(tp,1)
end

function s.eqmatfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end

function s.ffilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end

function s.b2_check(tp,e)
	local eqg=Duel.GetMatchingGroup(s.eqmatfilter,tp,LOCATION_SZONE,0,nil)
	local elist={}
	for tc in aux.Next(eqg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_MONSTER+TYPE_EFFECT)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_SETCODE)
		e2:SetValue(SET_CRYSTAL_FLOWER)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		e3:SetValue(1)
		tc:RegisterEffect(e3,true)
		table.insert(elist,e1)
		table.insert(elist,e2)
		table.insert(elist,e3)
	end
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_ONFIELD)
	local res=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	for _,eff in ipairs(elist) do
		eff:Reset()
	end
	return res
end

function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.b1_check(tp,e)
	local b2=s.b2_check(tp,e)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_GRAVE_ACTION)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.fusop(e,tp)
	local eqg=Duel.GetMatchingGroup(s.eqmatfilter,tp,LOCATION_SZONE,0,nil)
	local elist={}
	for tc in aux.Next(eqg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_MONSTER+TYPE_EFFECT)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_SETCODE)
		e2:SetValue(SET_CRYSTAL_FLOWER)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		e3:SetValue(1)
		tc:RegisterEffect(e3,true)
		table.insert(elist,e1)
		table.insert(elist,e2)
		table.insert(elist,e3)
	end
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_ONFIELD)
	local sg1=Duel.GetMatchingGroup(s.ffilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.ffilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	for _,eff in ipairs(elist) do
		eff:Reset()
	end
end

function s.operation3(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 分支1：选「狄娜托·图娜」与最多3张装备魔法卡返回卡组并抽1张
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter_mon),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
		if #g1==0 then return end
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter_eq),tp,LOCATION_GRAVE,0,nil)
		local sg=g1:Clone()
		if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg2=g2:Select(tp,1,3,nil)
			sg:Merge(sg2)
		end
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	else
		-- 分支2：手卡·场上融合（魔陷区装备卡可作「水晶花」素材）
		s.fusop(e,tp)
	end
end