--侦探栗子球
local s,id=GetID()
function s.initial_effect(c)
	--① 战斗阶段从手卡丢弃，确认对方卡组顶3张
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_POSITION+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_DAMAGE_STEP+TIMING_DAMAGE_CAL)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

-- 条件：战斗阶段
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end

-- cost：把这张卡从手卡丢弃
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

-- target
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=3 end
end

-- 处理
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,3)
	if g:GetCount()<3 then return end
	Duel.ConfirmDecktop(1-tp,3)
	
	-- ★ 改名，避免覆盖全局的 s
	local ct_m=g:FilterCount(Card.IsType,nil,TYPE_MONSTER)
	local ct_s=g:FilterCount(Card.IsType,nil,TYPE_SPELL)
	local ct_t=g:FilterCount(Card.IsType,nil,TYPE_TRAP)
	
	-- ●魔法卡
	if ct_s>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	
	-- ●陷阱卡
	if ct_t>0 then
		Duel.BreakEffect()
		local dg=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
		if dg:GetCount()>0 then
			Duel.ChangePosition(dg,POS_FACEUP_DEFENSE)
		end
	end
	
	-- ●怪兽卡
	if ct_m>0 then
		Duel.BreakEffect()
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
	
	-- 3种卡各有1张
	if ct_m>0 and ct_s>0 and ct_t>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

function s.posfilter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsCanTurnSet()
end

return s
