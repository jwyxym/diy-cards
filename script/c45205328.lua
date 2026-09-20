--侦探与医生 (45205326)
--字段：侦探
--光/魔法师族/效果/链接2
--↓→·1800
--包含光属性的魔法师族怪兽2只

local s,id=GetID()
s.fusion_effect=true

function s.initial_effect(c)
	-- ★★★ 链接素材：2只魔法师族怪兽，其中至少1只是光属性 ★★★
	aux.AddLinkProcedure(c, s.matfilter, 2, 2, s.matcheck)
	c:EnableReviveLimit()
	
	-- ①效果：链接召唤时宣言等级，翻卡组直到出现魔法师族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	
	-- ②效果：主要阶段，墓地怪兽回卡组，融合召唤魔法师族融合怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
	
	-- ③效果：自肃，不是魔法师族怪兽不能特殊召唤（离场失效）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end

-- ★★★ 链接素材过滤：必须是魔法师族 ★★★
function s.matfilter(c, lc, tp, sg)
	return c:IsRace(RACE_SPELLCASTER)
end

-- ★★★ 验证：2只素材中至少1只是光属性 ★★★
function s.matcheck(g)
	return g:GetCount()==2 and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT)
end

-- ①效果过滤：可以通常召唤的魔法师族怪兽
function s.spfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_SPELLCASTER) and c:IsSummonableCard()
end

-- ①效果过滤：可以特殊召唤的魔法师族怪兽
function s.spfilter2(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_SPELLCASTER) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ①效果目标
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		if not Duel.IsPlayerCanDiscardDeck(tp,1) then return false end
		return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end

-- ①效果处理
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanSpecialSummon(tp) or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp)
	
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil)
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local tc=g:GetFirst()
	local spcard=nil
	while tc do
		if tc:GetSequence()>seq then
			seq=tc:GetSequence()
			spcard=tc
		end
		tc=g:GetNext()
	end
	
	if seq==-1 then return end
	
	Duel.ConfirmDecktop(tp,dcount-seq)
	
	local remain=Group.CreateGroup()
	for i=1, dcount-seq do
		local tg=Duel.GetDecktopGroup(tp,1)
		if #tg>0 then
			remain:AddCard(tg:GetFirst())
		end
	end
	
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and spcard:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		if spcard:GetLevel()==lv then
			remain:RemoveCard(spcard)
			if #remain>0 then
				Duel.SendtoDeck(remain,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
			Duel.SpecialSummon(spcard,0,tp,tp,false,false,POS_FACEUP)
		else
			remain:RemoveCard(spcard)
			if #remain>0 then
				Duel.SendtoDeck(remain,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
			Duel.SendtoGrave(spcard,REASON_EFFECT)
		end
	else
		if #remain>0 then
			Duel.SendtoDeck(remain,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

-- ②效果过滤：墓地怪兽回卡组
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

-- ②效果过滤：融合怪兽（魔法师族）
function s.fufilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_SPELLCASTER)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,tp)
end

-- ②效果目标
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
		if #mg==0 then return false end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		return Duel.IsExistingMatchingCard(s.fufilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

-- ②效果处理
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if #mg==0 then return end
	
	local fg=Duel.GetMatchingGroup(s.fufilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
	if #fg==0 then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fc=fg:Select(tp,1,1,nil):GetFirst()
	if not fc then return end
	
	local mat=Duel.SelectFusionMaterial(tp,fc,mg,nil,tp)
	if not mat or #mat==0 then return end
	
	Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	
	Duel.BreakEffect()
	Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	fc:CompleteProcedure()
end

-- ③效果自肃
function s.splimit(e,c)
	return not c:IsRace(RACE_SPELLCASTER)
end

return s