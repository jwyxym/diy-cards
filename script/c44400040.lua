-- 水晶花·圣宣心 (ID: 44400040)
local s,id,o=GetID()
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段代码

-- 原本卡名包含「狄娜托」的怪兽清单
local DINATO_CODES = {
	[44400036]=true,
	[44400038]=true,
	[44400041]=true,
	[44400046]=true,
}

-- 原本卡名包含「水晶花」的怪兽清单
local CRYSTAL_FLOWER_CODES = {
	[44400033]=true,
	[44400034]=true,
	[44400040]=true,
}

function s.initial_effect(c)
	-- 同调召唤手续：调整＋调整以外的怪兽１只（必须置于最顶层，确保绝对成功注册）
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)

	-- 头部记录记述卡号（彻底删除虚构的 AddSetCardList）
	aux.AddCodeList(c,44400036,44400038,44400041,44400046,44400033,44400034)

	-- ①：自己主要阶段才能发动。自己抽１张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)

	-- ②：装备状态：双方主要阶段才能发动。选自己魔陷·墓地1只「水晶花」怪兽特召...（彻底修复堆栈溢出）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)

	-- ③：这张卡送去墓地的场合，以自己场上1只原本卡名包含「狄娜托」或「水晶花」的怪兽为对象才能发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_EQUIP+CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(s.eqtg3)
	e3:SetOperation(s.eqop3)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- ①效果：抽1张卡
--------------------------------------------------------------------------------
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

--------------------------------------------------------------------------------
-- ②效果：装备状态下发动（原生安全无死循环）
--------------------------------------------------------------------------------
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 必须作为装备卡装备着怪兽，且处于双方主要阶段
	return c:GetEquipTarget()~=nil and Duel.IsMainPhase() and Duel.GetFlagEffect(tp,id+100)==0
end

function s.spfilter2(c,e,tp)
	return c:IsSetCard(SET_CRYSTAL_FLOWER) and (c:GetOriginalType()&TYPE_MONSTER~=0)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id+100)==0
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 发动时立即打上本回合限制标记
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE+LOCATION_GRAVE)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己不能把装备中的「水晶花·圣宣心」的效果发动（客户端提示）
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,5))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0:SetCode(EFFECT_CANNOT_ACTIVATE)
	e0:SetTargetRange(1,0)
	e0:SetValue(s.aclimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

	-- 那之后，可以让那只怪兽的等级下降１
	if tc:IsFaceup() and tc:IsLevelAbove(2) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end

	-- 进行１次同调召唤。不能同调召唤的场合，这张卡以及这个效果特殊召唤的怪兽全部除外
	local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,0,nil)
	local syn_g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if #syn_g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=syn_g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		if sc then
			Duel.SynchroSummon(tp,sc,nil,mg)
		end
	else
		-- 不能同调召唤的场合，全部除外（装备怪兽 + 特召的怪兽）
		local rm_g=Group.CreateGroup()
		local eq_mon=c:GetEquipTarget()
		if eq_mon and eq_mon:IsFaceup() then rm_g:AddCard(eq_mon) end
		if tc:IsFaceup() then rm_g:AddCard(tc) end
		if #rm_g>0 then
			Duel.BreakEffect()
			Duel.Remove(rm_g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

-- 封锁判定：只封锁该卡的装备发动效果，不影响圣宣心自身怪兽状态的抽卡与墓地装备
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(id) and re:GetHandler():IsLocation(LOCATION_SZONE)
end

--------------------------------------------------------------------------------
-- ③效果：精确物理比对「狄娜托」与「水晶花」卡号
--------------------------------------------------------------------------------
function s.eqfilter3(c)
	if not (c:IsFaceup() and c:IsType(TYPE_MONSTER)) then return false end
	local code=c:GetOriginalCodeRule()
	return DINATO_CODES[code]
		or CRYSTAL_FLOWER_CODES[code]
		or c:IsOriginalSetCard(SET_CRYSTAL_FLOWER)
end

function s.eqtg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter3(chkc) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(s.eqfilter3,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter3,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end

function s.eqop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if Duel.Equip(tp,c,tc) then
		-- 装备限制
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(s.eqlimit3)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

		-- 那之后，可以把那只怪兽的等级变成７
		if tc:IsFaceup() and tc:IsLevelAbove(1) and not tc:IsLevel(7) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.BreakEffect()
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_LEVEL)
			e2:SetValue(7)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end

function s.eqlimit3(e,c)
	return c==e:GetLabelObject()
end