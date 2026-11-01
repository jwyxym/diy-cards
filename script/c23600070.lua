-- 天蚀超量蛾 (ID: 23600070)
local s,id,o=GetID()
local SET_ECLIPSE = 0xd92

function s.initial_effect(c)
	-- 超量召唤手续：6星怪兽×2只以上
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,6,2,nil,nil,99)

	-- ①：1回合1次，怪兽的效果在场上以外发动时，把这张卡1个超量素材取除才能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1) -- 场上1回合1次
	e1:SetCondition(s.discon1)
	e1:SetCost(s.discost1)
	e1:SetTarget(s.distg1)
	e1:SetOperation(s.disop1)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)

	-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时，把这张卡1个超量素材取除才能发动。那只怪兽的效果无效化，攻击力·守备力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(s.atkcon2)
	e2:SetCost(s.atkcost2)
	e2:SetTarget(s.atktg2)
	e2:SetOperation(s.atkop2)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end

-- ==================== ① 效果：无效场外怪兽效果 ====================
function s.discon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定：必须是怪兽效果，且发动时所在的位置不属于场上（包含手卡、墓地、除外、卡组、额外卡组）
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and (loc&LOCATION_ONFIELD==0)
		and Duel.IsChainDisablable(ev)
end

function s.discost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.distg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.disop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

-- ==================== ② 效果：战阶压制并减半攻防 ====================
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判定：必须与对方表侧表示怪兽进行战斗
	return bc and bc:IsControler(1-tp) and bc:IsFaceup()
end

function s.atkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,bc,1,0,0)
end

function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		-- 效果无效化（无截止回合描述，只要在场上表侧存在则持续无效）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)

		-- 攻击力减半（采用向上取整，避免奇数除不尽产生小数）
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(math.ceil(tc:GetAttack()/2))
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)

		-- 守备力减半（安全检查：连接怪兽无守备力，需规避连接怪兽报错）
		if not tc:IsType(TYPE_LINK) then
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e4:SetValue(math.ceil(tc:GetDefense()/2))
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e4)
		end
	end
end