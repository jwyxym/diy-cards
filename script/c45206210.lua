--截道鼠 吱助
local s,id=GetID()
function s.initial_effect(c)
	-- ★ 强制注册：这张卡记述了「格斗鼠 吱助」
	aux.AddCodeList(c, 8508055)

	c:EnableReviveLimit()
	-- 融合素材：兽族怪兽 + 通常怪兽
	aux.AddFusionProcMix(c,true,true,
		aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),
		aux.FilterBoolFunction(Card.IsType,TYPE_NORMAL))

	-- ★ 替代召唤手续：1回合1次，解放场上原本卡名为「格斗鼠 吱助」的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ★ 召唤条件限制
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)

	--① 场上表侧表示存在时，自己场上兽族怪兽攻守+1200
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg)
	e3:SetValue(1200)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3b)

	--② 对方把卡的效果发动时，那个效果无效并破坏
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)

	--③ 这张卡在场上也当作「格斗鼠 吱助」使用
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EFFECT_ADD_CODE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(8508055)
	c:RegisterEffect(e5)
end

-- ========== 替代特召手续 ==========

-- 检查是否为原版卡名「格斗鼠 吱助」（IsOriginalCodeRule 不会受效果改名影响）
function s.relfilter(c)
	return c:IsOriginalCodeRule(8508055) and c:IsReleasable()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFlagEffect(tp,id)==0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			sg:KeepAlive()
			e:SetLabelObject(sg)
			return true
		end
	end
	return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 注册标记，防止1回合重复使用
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local sg=e:GetLabelObject()
	Duel.Release(sg,REASON_COST)
	sg:DeleteGroup()
end

-- ========== ① 攻守上升过滤 ==========
function s.atktg(e,c)
	return c:IsRace(RACE_BEAST)
end

-- ========== ② 康效果 ==========
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainDisablable(ev)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local rc=re:GetHandler()
		if rc:IsRelateToEffect(re) and rc:IsDestructable() then
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end

return s
