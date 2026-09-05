-- 混沌No.102 阴影傀儡 贵魔 (ID: 20263242)
local s,id,o=GetID()
local SET_STAR_SERAPH=0x86 -- 「光天使」官方字段代码

function s.initial_effect(c)
	-- Xyz 召唤手续：5星怪兽 × 4
	aux.AddXyzProcedure(c,nil,5,4)
	c:EnableReviveLimit()

	-- 规则效果：在规则上也当作「光天使」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(SET_STAR_SERAPH)
	c:RegisterEffect(e0)

	-- 特殊重叠召唤：1回合1次，在自己·对方场上的4阶超量怪兽上方叠放，从额外卡组到对方场上超量召唤 (HOPT: id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP,1) -- 1: 召唤至对方场上
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.ovcon)
	e1:SetTarget(s.ovtg)
	e1:SetOperation(s.ovop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)

	-- ①：超量召唤成功的场合强制发动：去除1素材，双方各抽1张并受到1000伤害
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.drcon)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)

	-- ②：其他光属性怪兽发动效果时强制发动：去除1素材，双方可选特召4星以下光·暗怪兽（效果无效），未特召者受500伤害
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.spcon2)
	e3:SetCost(s.spcost2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)

	-- ③：超量素材全部被取除的场合强制发动：其他己方怪兽攻变0且无效，自身回到额外卡组
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DETACH_MATERIAL)
	e4:SetCondition(s.wipecon)
	e4:SetTarget(s.wipetg)
	e4:SetOperation(s.wipeop)
	c:RegisterEffect(e4)
end

-- ==================== 特殊重叠召唤到对方场上 ====================
function s.ovfilter(c,xyzc,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(4)
		and c:IsCanBeXyzMaterial(xyzc)
		and Duel.GetLocationCountFromEx(1-tp,tp,c,xyzc)>0
end

function s.ovcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c,tp)
end

function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local cancel=Duel.IsSummonCancelable()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end

function s.ovop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	local tc=g:GetFirst()
	local mg=tc:GetOverlayGroup()
	if #mg>0 then
		Duel.Overlay(c,mg)
	end
	c:SetMaterial(g)
	Duel.Overlay(c,g)
	g:DeleteGroup()
end

-- ==================== ① 效果：出场抽卡并受1000伤害 ====================
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local d1=Duel.Draw(tp,1,REASON_EFFECT)
	local d2=Duel.Draw(1-tp,1,REASON_EFFECT)
	if d1>0 or d2>0 then
		Duel.BreakEffect()
		if d1>0 and d2>0 then
			Duel.Damage(tp,1000,REASON_EFFECT,true)
			Duel.Damage(1-tp,1000,REASON_EFFECT,true)
		elseif d1>0 then
			Duel.Damage(tp,1000,REASON_EFFECT)
		elseif d2>0 then
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end

-- ==================== ② 效果：光属性发动效果时特召光·暗怪兽（效果无效） ====================
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	return rc and rc~=c and re:IsActiveType(TYPE_MONSTER) and rc:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,PLAYER_ALL,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter2,1-tp,LOCATION_DECK,0,1,nil,e,1-tp)

	local sp1=false
	local sp2=false

	-- 自己选择是否特召
	if b1 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc1=g1:GetFirst()
		if tc1 then
			-- ★ 核心修复：必须在 SpecialSummonStep 成功后（落地到场上后）再注册无效效果，防止被 RESET_TOFIELD 误抹除！
			if Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP) then
				sp1=true
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc1:RegisterEffect(e1,true)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc1:RegisterEffect(e2,true)
			end
		end
	end

	-- 对方选择是否特召
	if b2 and Duel.SelectYesNo(1-tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(1-tp,s.spfilter2,1-tp,LOCATION_DECK,0,1,1,nil,e,1-tp)
		local tc2=g2:GetFirst()
		if tc2 then
			-- ★ 核心修复：必须在 SpecialSummonStep 成功后（落地到场上后）再注册无效效果，防止被 RESET_TOFIELD 误抹除！
			if Duel.SpecialSummonStep(tc2,0,1-tp,1-tp,false,false,POS_FACEUP) then
				sp2=true
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc2:RegisterEffect(e1,true)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc2:RegisterEffect(e2,true)
			end
		end
	end

	Duel.SpecialSummonComplete()

	-- 未进行特殊召唤的玩家受到 500 点伤害
	if not sp1 or not sp2 then
		Duel.BreakEffect()
		if not sp1 and not sp2 then
			Duel.Damage(tp,500,REASON_EFFECT,true)
			Duel.Damage(1-tp,500,REASON_EFFECT,true)
		elseif not sp1 then
			Duel.Damage(tp,500,REASON_EFFECT)
		elseif not sp2 then
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end

-- ==================== ③ 效果：素材归零全场攻击变0且无效，自身回额外 ====================
function s.wipecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:GetOverlayCount()==0
end

function s.wipetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end

function s.wipeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 1. 除这张卡以外的自己场上怪兽攻击力变为0，效果无效化
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3)
	end
	-- 2. 这张卡回到原本持有者的额外卡组
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.BreakEffect()
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end