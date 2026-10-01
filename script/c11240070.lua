-- 永夜的妖龙 阿波菲斯 (ID: 11240070)
local s,id,o=GetID()
local SET_YONGYE=0xb92   -- 「永夜」字段
local CARD_KNIGHT=11240055 -- 「永夜的骑士」卡号

function s.initial_effect(c)
	-- 融合召唤手续：融合·同调·超量·连接怪兽 ＋ 「永夜」怪兽
	c:EnableReviveLimit()
	aux.AddCodeList(c,CARD_KNIGHT)
	aux.AddFusionProcMix(c,true,true,s.matfilter1,s.matfilter2)

	-- ①：特殊召唤成功的场合才能发动。卡组特召1只「永夜」怪兽。若是「永夜的骑士」则自身获得全卡发动抗性至下个回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ②：自己·对方回合，二选一适用：攻击力大幅上升（支持伤步） / 解放自身全场怪兽变暗属性
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP) -- 核心修复 1：允许在伤害步骤发动
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	-- 核心修复 2：加入 TIMING_DAMAGE_STEP 提示时点，并规避 TIMINGS_CHECK_MONSTER_E 违规宏
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_SUMMON+TIMING_SPSUMMON+TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCondition(aux.dscon) -- 核心修复 3：标准伤步时点安全判定（伤害计算前）
	e2:SetTarget(s.efftg2)
	e2:SetOperation(s.effop2)
	c:RegisterEffect(e2)
end

-- ==================== 融合素材过滤 ====================

function s.matfilter1(c,fc,sub,mg,sg)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,fc,sub,mg,sg)
end

function s.matfilter2(c,fc,sub,mg,sg)
	return c:IsSetCard(SET_YONGYE,fc,sub,mg,sg)
end

-- ==================== ① 效果逻辑 ====================

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local c=e:GetHandler()
		-- 若特召的是「永夜的骑士」，赋予自身全卡发动效果免疫至下个回合结束
		if tc:IsCode(CARD_KNIGHT) and c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.BreakEffect()
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3111) -- 系统原生提示文本：不受其他卡发动的效果影响
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e1)
		end
	end
end

-- 不受其他卡发动的效果影响
function s.efilter(e,te)
	return te:GetHandler()~=e:GetHandler() and te:IsActivated()
end

-- ==================== ② 效果逻辑 ====================

function s.darkfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.darkatkfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:GetAttack()>0
end

function s.efftg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local in_damage=(Duel.GetCurrentPhase()==PHASE_DAMAGE)

	-- 分支 1 判定：自身表侧在场且场上有攻击力大于0的暗属性怪兽（伤害步骤中始终合法）
	local b1=c:IsFaceup() and Duel.IsExistingMatchingCard(s.darkatkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 分支 2 判定：自身可以被效果解放（核心修复 4：伤害步骤中严格禁止发动变属性效果）
	local b2=not in_damage and c:IsReleasableByEffect()

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
		e:SetCategory(CATEGORY_ATKCHANGE)
	else
		e:SetCategory(CATEGORY_RELEASE)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,c,1,0,0)
	end
end

function s.effop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()

	if op==0 then
		-- 分支 1：攻击力上升场上暗属性怪兽攻击力合计数值至下个回合结束
		local g=Duel.GetMatchingGroup(s.darkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local atk=0
		for tc in aux.Next(g) do
			local val=tc:GetAttack()
			if val>0 then atk=atk+val end
		end
		if c:IsRelateToEffect(e) and c:IsFaceup() and atk>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e1)
		end
	else
		-- 分支 2：解放自身，直到回合结束场上的表侧表示怪兽变成暗属性
		if c:IsRelateToEffect(e) and Duel.Release(c,REASON_EFFECT)>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e1:SetValue(ATTRIBUTE_DARK)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end