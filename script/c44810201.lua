--击发！决定你的命运！
local s,id=GetID()
local FLAG_DECLARED_CODE=id+1000

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE+CATEGORY_TOGRAVE+CATEGORY_ANNOUNCE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

----------------------------------------------------------------
-- Cost：把手卡全部丢弃，并宣言1个怪兽卡名
----------------------------------------------------------------
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		g:RemoveCard(e:GetHandler())
		return g:GetCount()>0 and g:FilterCount(Card.IsDiscardable,nil)==g:GetCount()
	end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE}
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end

----------------------------------------------------------------
-- Target
----------------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,5,tp,LOCATION_DECK)
	if e:IsCostChecked() and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end

----------------------------------------------------------------
-- Operation
----------------------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if code==0 then return end
	local g=Duel.GetDecktopGroup(tp,5)
	if #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end

	-- 直到对方回合结束时，宣言的怪兽不会被战斗·效果破坏
	s.apply_indestructable(e,tp,code)

	-- 那之后，可以让以下效果适用：翻开卡组最上面的卡
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end -- "是否翻开卡组最上面的卡"
	Duel.BreakEffect()
	local top=Duel.GetDecktopGroup(tp,1):GetFirst()
	if not top then return end
	Duel.ConfirmDecktop(tp,1)
	if top:IsCode(code) and top:IsType(TYPE_MONSTER) then
		-- 送去墓地
		Duel.SendtoGrave(top,REASON_EFFECT)
		if top:IsLocation(LOCATION_GRAVE) then
			local atk=top:GetAttack()
			if atk<0 then atk=0 end
			-- 给与对方 攻击力×6 的伤害
			Duel.Damage(1-tp,atk*6,REASON_EFFECT)
		end
	else
	end
end
function s.apply_indestructable(e,tp,code)
	local c=e:GetHandler()
	-- 战斗破坏抗性
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsCode(code) end)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	Duel.RegisterEffect(e1,tp)
	-- 效果破坏抗性
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	Duel.RegisterEffect(e2,tp)
end
