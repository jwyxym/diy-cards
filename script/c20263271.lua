-- 王家魔族王者归来！ (ID: 20263271)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：可以从以下效果中选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	-- 分支 ●1：以对方场上1只3星以上的怪兽为对象才能发动。那只怪兽的等级下降2星，从卡组把1张「王家魔族」怪兽加入手卡。那之后，自己场上没有怪兽存在的场合，可以再从卡组把1张「王家魔族」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id) -- ●1 独立 HOPT
	e1:SetCondition(s.con1)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- 分支 ●2：对方对应「王家魔族」卡的效果的发动把卡的效果发动时，丢弃1张手卡才能发动（自己场上没有怪兽存在的场合，对方不能对应这个效果的发动把卡的效果发动）。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id+o*100) -- ●2 独立 HOPT（防撞车规范 id+o*100）
	e2:SetCondition(s.con2)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

-- ==================== 分支 ●1 相关处理 ====================
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家 Flag 状态锁：彻底规避复制类效果绕过 HOPT
	return Duel.GetFlagEffect(tp,id)==0
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

function s.tgfilter1(c)
	return c:IsFaceup() and c:IsLevelAbove(3)
end

function s.thfilter_mon(c)
	return c:IsSetCard(0x321) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thfilter_st(c)
	return c:IsSetCard(0x321) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter1(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.tgfilter1,tp,0,LOCATION_MZONE,1,nil)
			and Duel.IsExistingMatchingCard(s.thfilter_mon,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter1,tp,0,LOCATION_MZONE,1,1,nil)
	-- 严格使用原生标准的 SetOperationInfo
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 等级下降2星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)

		-- 从卡组把1张「王家魔族」怪兽加入手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter_mon,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,g)
			-- 那之后，自己场上没有怪兽存在的场合，可以再从卡组把1张「王家魔族」魔法·陷阱卡加入手卡
			if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 then
				local sg=Duel.GetMatchingGroup(s.thfilter_st,tp,LOCATION_DECK,0,nil)
				if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
					local tg=sg:Select(tp,1,1,nil)
					Duel.SendtoHand(tg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,tg)
				end
			end
		end
	end
end

-- ==================== 分支 ●2 相关处理 ====================
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家 Flag 状态锁
	if Duel.GetFlagEffect(tp,id+o*100)>0 then return false end
	-- 对方发动效果，当前链节点可以被无效，且必须是对应上一个效果发动
	if rp==tp or not Duel.IsChainDisablable(ev) or ev<=1 then return false end
	local pe=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	-- 上一个链节点必须是「王家魔族」卡或其效果的发动
	return pe and pe:GetHandler():IsSetCard(0x321)
end

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 排除自身，防止从手卡发动时把自己当成手卡代价丢弃导致死锁
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
	end
	Duel.RegisterFlagEffect(tp,id+o*100,RESET_PHASE+PHASE_END,0,1)
	Duel.DiscardHand(tp,nil,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end

function s.chlimit(e,ep,tp)
	return tp==ep
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 自己场上没有怪兽存在的场合，对方不能对应这个效果的发动把卡的效果发动
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 then
		Duel.SetChainLimit(s.chlimit)
	end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end